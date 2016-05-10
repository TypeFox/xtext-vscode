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
import io.typefox.lsapi.CompletionItemImpl
import io.typefox.lsapi.CompletionOptionsImpl
import io.typefox.lsapi.DidChangeTextDocumentParamsImpl
import io.typefox.lsapi.DidCloseTextDocumentParams
import io.typefox.lsapi.DidOpenTextDocumentParamsImpl
import io.typefox.lsapi.DidSaveTextDocumentParams
import io.typefox.lsapi.InitializeResultImpl
import io.typefox.lsapi.InvalidMessageException
import io.typefox.lsapi.Message
import io.typefox.lsapi.NotificationMessage
import io.typefox.lsapi.RequestMessage
import io.typefox.lsapi.ResponseError
import io.typefox.lsapi.ResponseMessage
import io.typefox.lsapi.ResponseMessageImpl
import io.typefox.lsapi.ServerCapabilities
import io.typefox.lsapi.ServerCapabilitiesImpl
import io.typefox.lsapi.TextDocumentIdentifier
import io.typefox.lsapi.TextDocumentIdentifierImpl
import io.typefox.lsapi.TextDocumentItemImpl
import io.typefox.lsapi.TextDocumentPositionParamsImpl
import io.typefox.lsapi.VersionedTextDocumentIdentifier
import io.typefox.lsapi.VersionedTextDocumentIdentifierImpl
import io.typefox.xtext.vscode.validation.NotifyingValidationService
import java.io.IOException
import org.eclipse.xtext.util.TextRegion
import org.eclipse.xtext.util.internal.Log
import org.eclipse.xtext.web.server.contentassist.ContentAssistService
import org.eclipse.xtext.web.server.model.PrecomputedServiceRegistry
import org.eclipse.xtext.web.server.model.XtextWebDocument
import org.eclipse.xtext.web.server.model.XtextWebDocumentAccess
import org.eclipse.xtext.web.server.persistence.IServerResourceHandler

@Singleton
@Log
class VSCodeServiceDispatcher {
	
	@Inject ContentAssistService contentAssistService
	@Inject NotifyingValidationService validationService
	@Inject IServerResourceHandler resourceHandler
	@Inject XtextWebDocumentAccess.Factory documentAccessFactory
	@Inject extension DocumentPositionHelper
	
	@Inject
	protected def void registerPreComputedServices(PrecomputedServiceRegistry registry) {
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
				throw new InvalidMessageException("Invalid message type.", null)
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
				throw new InvalidMessageException('The method ' + methodName + ' is not supported.', messageId, ResponseError.METHOD_NOT_FOUND)
		}
		return null
	}
	
	protected def configure(ServerCapabilitiesImpl it) {
		textDocumentSync = ServerCapabilities.SYNC_INCREMENTAL
		completionProvider = new CompletionOptionsImpl
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
				throw new InvalidMessageException("Invalid message type.", messageId)
		if (paramType.isInstance(params))
			return paramType.cast(params)
		else
			throw new InvalidMessageException("Invalid message parameters.", messageId, ResponseError.INVALID_PARAMS)
	}
	
	protected def String getMessageId(IServiceContext context) {
		val message = context.message
		if (message instanceof RequestMessage)
			return message.id
	}
	
	protected def ResponseMessage respond(Object result, IServiceContext context) {
		val response = new ResponseMessageImpl
		response.id = context.messageId
		response.result = result
		return response
	}
	
	protected def initialize(IServiceContext context) {
		val result = new InitializeResultImpl => [
			capabilities = configure(new ServerCapabilitiesImpl)
		]
		respond(result, context)
	}
	
	protected def void documentOpened(IServiceContext context) {
		val params = context.getRequestParams(DidOpenTextDocumentParamsImpl)
		// Support protocol version 1.0
		if (params.textDocument === null)
			params.textDocument = new TextDocumentItemImpl => [
				uri = params.uri
				text = params.text
			]
		val document = getDocumentAccess(params, context)
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
		val params = context.getRequestParams(DidChangeTextDocumentParamsImpl)
		// Support protocol version 1.0
		if (params.textDocument === null && params.uri !== null)
			params.textDocument = new VersionedTextDocumentIdentifierImpl => [uri = params.uri]
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
		val params = context.getRequestParams(TextDocumentPositionParamsImpl)
		// Support protocol version 1.0
		if (params.textDocument === null)
			params.textDocument = new TextDocumentIdentifierImpl => [uri = params.uri]
		val document = getDocumentAccess(params.textDocument, context)
		val offset = document.getOffset(params.position)
		val selection = new TextRegion(offset, 0)
		val proposals = contentAssistService.createProposals(document, selection, offset, ContentAssistService.DEFAULT_PROPOSALS_LIMIT)
		val result = proposals.entries.map[ entry |
			new CompletionItemImpl => [
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
			throw new InvalidMessageException('The requested resource was not found.', context.messageId)
		}
	}
	
}
