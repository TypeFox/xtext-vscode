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
import java.io.IOException
import org.eclipse.xtext.util.TextRegion
import org.eclipse.xtext.util.internal.Log
import org.eclipse.xtext.web.server.contentassist.ContentAssistService
import org.eclipse.xtext.web.server.model.PrecomputedServiceRegistry
import org.eclipse.xtext.web.server.model.XtextWebDocument
import org.eclipse.xtext.web.server.model.XtextWebDocumentAccess
import org.eclipse.xtext.web.server.persistence.IServerResourceHandler
import org.eclipse.xtext.web.server.syntaxcoloring.HighlightingService
import org.eclipse.xtext.web.server.validation.ValidationService
import io.typefox.xtext.vscode.protocol.CompletionItem
import io.typefox.xtext.vscode.protocol.Message
import io.typefox.xtext.vscode.protocol.NotificationMessage
import io.typefox.xtext.vscode.protocol.Position
import io.typefox.xtext.vscode.protocol.RequestMessage
import io.typefox.xtext.vscode.protocol.ResponseMessage
import io.typefox.xtext.vscode.protocol.TextDocumentIdentifier
import io.typefox.xtext.vscode.protocol.VersionedTextDocumentIdentifier
import io.typefox.xtext.vscode.protocol.options.ServerCapabilities
import io.typefox.xtext.vscode.protocol.params.TextDocumentPositionParams
import io.typefox.xtext.vscode.protocol.result.InitializeResult
import io.typefox.xtext.vscode.protocol.options.CompletionOptions
import io.typefox.xtext.vscode.protocol.ResponseError

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
				initialize(context)
			case 'textDocument/completion':
				callContentAssistService(context)
			default:
				throw new InvalidRequestException('The method ' + methodName + ' is not supported.', messageId, ResponseError.METHOD_NOT_FOUND)
		}
	}
	
	protected def configure(ServerCapabilities it) {
		textDocumentSync = ServerCapabilities.SYNC_NONE
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
	
	protected def callContentAssistService(IServiceContext context) {
		val params = context.getRequestParams(TextDocumentPositionParams)
		val document = getDocumentAccess(params.textDocument, context)
		val offset = document.getOffset(params.position)
		val selection = new TextRegion(offset, 0)
		val proposals = contentAssistService.createProposals(document, selection, offset, ContentAssistService.DEFAULT_PROPOSALS_LIMIT)
		val result = proposals.entries.map[ entry |
			new CompletionItem => [
				label = entry.label
				detail = entry.description
				insertText = entry.proposal
			]
		].toArray
		respond(result, context)
	}
	
	protected def getDocumentAccess(TextDocumentIdentifier docIdentifier, IServiceContext context) {
		val document = getResourceDocument(docIdentifier.uri, context)
		if (document === null)
			throw new InvalidRequestException('The requested resource was not found.', context.messageId)
		val requiredStateId = if (docIdentifier instanceof VersionedTextDocumentIdentifier)
			Integer.toString(docIdentifier.version)
		return documentAccessFactory.create(document, requiredStateId, false)
	}
	
	/**
	 * Obtain a document from the session store, and if it is not present there, ask the
	 * {@link IServerResourceHandler} to provide it. In case that resource handler fails
	 * to provide the document, {@code null} is returned instead.
	 */
	protected def getResourceDocument(String resourceId, IServiceContext context) {
		try {
			val document = context.session.get(XtextWebDocument -> resourceId, [
				resourceHandler.get(resourceId, new ServiceContextAdapter(context))
			])
			return document
		} catch (IOException ioe) {
			return null
		}
	}
	
	protected def int getOffset(XtextWebDocumentAccess document, Position position) {
		document.readOnly[ it, cancelIndicator |
			var row = 0
			var col = 0
			var offset = 0
			while (offset < text.length && row < position.line && col < position.character) {
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
		]
	}
	
}
