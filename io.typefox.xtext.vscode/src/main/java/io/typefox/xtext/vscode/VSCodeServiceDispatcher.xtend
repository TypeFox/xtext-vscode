/*******************************************************************************
 * Copyright (c) 2016 TypeFox GmbH (http://www.typefox.io) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
 package io.typefox.xtext.vscode

import com.google.inject.Inject
import com.google.inject.Singleton
import io.typefox.xtext.vscode.protocol.CompletionItem
import io.typefox.xtext.vscode.protocol.Message
import io.typefox.xtext.vscode.protocol.NotificationMessage
import io.typefox.xtext.vscode.protocol.Position
import io.typefox.xtext.vscode.protocol.RequestMessage
import io.typefox.xtext.vscode.protocol.ResponseError
import io.typefox.xtext.vscode.protocol.ResponseMessage
import io.typefox.xtext.vscode.protocol.TextDocumentIdentifier
import io.typefox.xtext.vscode.protocol.TextDocumentItem
import io.typefox.xtext.vscode.protocol.VersionedTextDocumentIdentifier
import io.typefox.xtext.vscode.protocol.options.CompletionOptions
import io.typefox.xtext.vscode.protocol.options.ServerCapabilities
import io.typefox.xtext.vscode.protocol.params.DidChangeTextDocumentParams
import io.typefox.xtext.vscode.protocol.params.DidCloseTextDocumentParams
import io.typefox.xtext.vscode.protocol.params.DidOpenTextDocumentParams
import io.typefox.xtext.vscode.protocol.params.DidSaveTextDocumentParams
import io.typefox.xtext.vscode.protocol.params.TextDocumentPositionParams
import io.typefox.xtext.vscode.protocol.result.InitializeResult
import java.io.IOException
import org.eclipse.xtext.util.TextRegion
import org.eclipse.xtext.util.internal.Log
import org.eclipse.xtext.web.server.contentassist.ContentAssistService
import org.eclipse.xtext.web.server.model.IXtextWebDocument
import org.eclipse.xtext.web.server.model.PrecomputedServiceRegistry
import org.eclipse.xtext.web.server.model.XtextWebDocument
import org.eclipse.xtext.web.server.model.XtextWebDocumentAccess
import org.eclipse.xtext.web.server.persistence.IServerResourceHandler
import org.eclipse.xtext.web.server.syntaxcoloring.HighlightingService
import org.eclipse.xtext.web.server.validation.ValidationService

@Singleton
@Log
class VSCodeServiceDispatcher {
	
	@Inject ContentAssistService contentAssistService
	@Inject ValidationService validationService
	@Inject HighlightingService highlightingService
	@Inject IServerResourceHandler resourceHandler
	@Inject XtextWebDocumentAccess.Factory documentAccessFactory
	
	@Inject
	protected def void registerPreComputedServices(PrecomputedServiceRegistry registry) {
		registry.addPrecomputedService(highlightingService)
		registry.addPrecomputedService(validationService)
	}
	
	def Message callService(IServiceContext context) {
		val message = context.message
		val messageId = if (message instanceof RequestMessage) message.id
		val methodName =
			if (message instanceof RequestMessage)
				message.method
			else if (message instanceof NotificationMessage)
				message.method
			else
				throw new InvalidRequestException("Invalid message type.", null)
		switch methodName {
			case 'initialize':
				return initialize(context)
			case 'textDocument/didOpen':
				documentOpened(context)
			case 'textDocument/didChange':
				documentChanged(context)
			case 'textDocument/didSave':
				documentSaved(context)
			case 'textDocument/didClose':
				documentClosed(context)
			case 'textDocument/completion':
				return callContentAssistService(context)
			default:
				throw new InvalidRequestException('The method ' + methodName + ' is not supported.', messageId, ResponseError.METHOD_NOT_FOUND)
		}
		return null
	}
	
	protected def configure(ServerCapabilities it) {
		textDocumentSync = ServerCapabilities.SYNC_INCREMENTAL
		completionProvider = new CompletionOptions
		return it
	}
	
	protected def <T> T getRequestParams(IServiceContext context, Class<T> paramType) {
		val message = context.message
		val messageId = if (message instanceof RequestMessage) message.id
		val params =
			if (message instanceof RequestMessage)
				message.params
			else if (message instanceof NotificationMessage)
				message.params
			else
				throw new InvalidRequestException("Invalid message type.", messageId)
		if (paramType.isInstance(params))
			return paramType.cast(params)
		else
			throw new InvalidRequestException("Invalid message parameters.", messageId, ResponseError.INVALID_PARAMS)
	}
	
	protected def String getMessageId(IServiceContext context) {
		val message = context.message
		if (message instanceof RequestMessage)
			return message.id
	}
	
	protected def ResponseMessage respond(Object result, IServiceContext context) {
		val response = new ResponseMessage
		response.jsonrpc = LanguageServer.JSONRPC_VERSION
		response.id = context.messageId
		response.result = result
		return response
	}
	
	protected def initialize(IServiceContext context) {
		val result = new InitializeResult => [
			capabilities = configure(new ServerCapabilities)
		]
		respond(result, context)
	}
	
	protected def void documentOpened(IServiceContext context) {
		val params = context.getRequestParams(DidOpenTextDocumentParams)
		val document = getDocumentAccess(params, context)
		// Support protocol version 1.0
		if (params.textDocument === null && params.text !== null)
			params.textDocument = new TextDocumentItem => [
				uri = params.uri
				text = params.text
			]
		if (params.textDocument?.text !== null) {
			document.modify[ it, cancelIndicator |
				text = params.textDocument.text
				if (params.textDocument.version != 0)
					resource.modificationStamp = params.textDocument.version
				return null
			]
		}
	}
	
	protected def void documentChanged(IServiceContext context) {
		val params = context.getRequestParams(DidChangeTextDocumentParams)
		// Support protocol version 1.0
		if (params.textDocument === null && params.uri !== null)
			params.textDocument = new VersionedTextDocumentIdentifier => [uri = params.uri]
		val document = getDocumentAccess(params.textDocument, context)
		document.modify[ it, cancelIndicator |
			dirty = true
			for (change : params.contentChanges) {
				val offset = getOffset(change.range.start)
				updateText(change.text, offset, change.rangeLength)
			}
			if (params.textDocument.version != 0)
				resource.modificationStamp = params.textDocument.version
			return null
		]
	}
	
	protected def void documentSaved(IServiceContext context) {
		val params = context.getRequestParams(DidSaveTextDocumentParams)
		val document = getDocumentAccess(params.textDocument, context)
		document.modify[ it, cancelIndicator |
			dirty = false
			return null
		]
	}
	
	protected def void documentClosed(IServiceContext context) {
		val params = context.getRequestParams(DidCloseTextDocumentParams)
		context.session.remove(XtextWebDocument -> params.textDocument.uri)
	}
	
	protected def callContentAssistService(IServiceContext context) {
		val params = context.getRequestParams(TextDocumentPositionParams)
		// Support protocol version 1.0
		if (params.textDocument === null && params.uri !== null)
			params.textDocument = new TextDocumentIdentifier => [uri = params.uri]
		val document = getDocumentAccess(params.textDocument, context)
		val offset = document.getOffset(params.position)
		val selection = new TextRegion(offset, 0)
		val proposals = contentAssistService.createProposals(document, selection, offset, ContentAssistService.DEFAULT_PROPOSALS_LIMIT)
		val result = proposals.entries.map[ entry |
			new CompletionItem => [
				label = entry.label ?: entry.proposal
				detail = entry.description
				insertText = entry.proposal
			]
		].toArray
		respond(result, context)
	}
	
	protected def getDocumentAccess(TextDocumentIdentifier docIdentifier, IServiceContext context) {
		getDocumentAccess(docIdentifier, context, false)
	}
	
	protected def getDocumentAccess(TextDocumentIdentifier docIdentifier, IServiceContext context,
			boolean includeRequiredStateId) {
		val document = getResourceDocument(docIdentifier.uri, context)
		val requiredStateId = if (includeRequiredStateId && docIdentifier instanceof VersionedTextDocumentIdentifier)
			Integer.toString((docIdentifier as VersionedTextDocumentIdentifier).version)
		return documentAccessFactory.create(document, requiredStateId, false)
	}
	
	protected def getResourceDocument(String resourceId, IServiceContext context) {
		try {
			val document = context.session.get(XtextWebDocument -> resourceId, [
				resourceHandler.get(resourceId, new ServiceContextAdapter(context))
			])
			return document
		} catch (IOException ioe) {
			throw new InvalidRequestException('The requested resource was not found.', context.messageId)
		}
	}
	
	protected def int getOffset(XtextWebDocumentAccess document, Position position) {
		document.readOnly[it, cancelIndicator | getOffset(position)]
	}
	
	protected def int getOffset(IXtextWebDocument document, Position position) {
		var row = 0
		var col = 0
		var offset = 0
		val text = document.text
		while (offset < text.length && (row < position.line || col < position.character)) {
			val c = text.charAt(offset)
			if (c == '\n'.charAt(0)) {
				row++
				col = 0
			} else {
				col++
			}
			offset++
		}
		return offset
	}
	
}
