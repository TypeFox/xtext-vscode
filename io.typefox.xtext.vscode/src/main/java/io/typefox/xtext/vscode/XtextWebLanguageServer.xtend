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
import io.typefox.lsapi.CodeActionParams
import io.typefox.lsapi.CodeLens
import io.typefox.lsapi.CodeLensParams
import io.typefox.lsapi.CompletionItem
import io.typefox.lsapi.DidChangeConfigurationParams
import io.typefox.lsapi.DidChangeTextDocumentParams
import io.typefox.lsapi.DidChangeWatchedFilesParams
import io.typefox.lsapi.DidCloseTextDocumentParams
import io.typefox.lsapi.DidOpenTextDocumentParams
import io.typefox.lsapi.DidSaveTextDocumentParams
import io.typefox.lsapi.DocumentFormattingParams
import io.typefox.lsapi.DocumentOnTypeFormattingParams
import io.typefox.lsapi.DocumentRangeFormattingParams
import io.typefox.lsapi.DocumentSymbolParams
import io.typefox.lsapi.InitializeParams
import io.typefox.lsapi.MessageParams
import io.typefox.lsapi.PublishDiagnosticsParams
import io.typefox.lsapi.ReferenceParams
import io.typefox.lsapi.RenameParams
import io.typefox.lsapi.ShowMessageRequestParams
import io.typefox.lsapi.TextDocumentIdentifier
import io.typefox.lsapi.TextDocumentItem
import io.typefox.lsapi.TextDocumentPositionParams
import io.typefox.lsapi.TextDocumentSyncKind
import io.typefox.lsapi.WorkspaceSymbolParams
import io.typefox.lsapi.impl.CompletionItemImpl
import io.typefox.lsapi.impl.CompletionListImpl
import io.typefox.lsapi.impl.CompletionOptionsImpl
import io.typefox.lsapi.impl.DiagnosticImpl
import io.typefox.lsapi.impl.InitializeResultImpl
import io.typefox.lsapi.impl.PublishDiagnosticsParamsImpl
import io.typefox.lsapi.impl.ServerCapabilitiesImpl
import io.typefox.lsapi.services.LanguageServer
import io.typefox.lsapi.services.TextDocumentService
import io.typefox.lsapi.services.WindowService
import io.typefox.lsapi.services.WorkspaceService
import io.typefox.lsapi.services.json.InvalidMessageException
import io.typefox.xtext.vscode.validation.NotifyingValidationService
import java.io.IOException
import java.util.ArrayList
import java.util.List
import java.util.concurrent.CompletableFuture
import java.util.function.Consumer
import org.eclipse.xtext.util.TextRegion
import org.eclipse.xtext.util.Wrapper
import org.eclipse.xtext.web.server.contentassist.ContentAssistService
import org.eclipse.xtext.web.server.model.PrecomputedServiceRegistry
import org.eclipse.xtext.web.server.model.XtextWebDocument
import org.eclipse.xtext.web.server.model.XtextWebDocumentAccess
import org.eclipse.xtext.web.server.persistence.IServerResourceHandler

@Singleton
class XtextWebLanguageServer implements LanguageServer, TextDocumentService, WindowService, WorkspaceService {
	
	@Inject ContentAssistService contentAssistService
	@Inject NotifyingValidationService validationService
	@Inject IServerResourceHandler resourceHandler
	@Inject XtextWebDocumentAccess.Factory documentAccessFactory
	@Inject extension DocumentPositionHelper
	
	val session = new HashMapSession
	
	val List<Consumer<PublishDiagnosticsParams>> diagnosticsCallbacks = newArrayList
	val List<Consumer<MessageParams>> logMessageCallbacks = newArrayList
	val List<Consumer<MessageParams>> showMessageCallbacs = newArrayList
	val List<Consumer<ShowMessageRequestParams>> showMessageRequestCallbacs = newArrayList
	
	@Inject
	protected def void registerPrecomputedServices(PrecomputedServiceRegistry registry) {
		registry.addPrecomputedService(validationService)
	}
	
	override getTextDocumentService() {
		this
	}
	
	override getWindowService() {
		this
	}
	
	override getWorkspaceService() {
		this
	}
	
	protected def configure(ServerCapabilitiesImpl it) {
		textDocumentSync = TextDocumentSyncKind.Incremental
		completionProvider = new CompletionOptionsImpl
		return it
	}
	
	override initialize(InitializeParams params) {
		val result = new InitializeResultImpl => [
			capabilities = configure(new ServerCapabilitiesImpl)
		]
		CompletableFuture.completedFuture(result)
	}
	
	override shutdown() {
		session.clear()
	}
	
	override exit() {
		// Nothing to do here
	}
	
	override onTelemetryEvent(Consumer<Object> callback) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	protected def getDocumentAccess(TextDocumentIdentifier docIdentifier) {
		getDocumentAccess(docIdentifier.uri, null)
	}
	
	protected def getDocumentAccess(TextDocumentItem docItem) {
		getDocumentAccess(docItem.uri, null)
	}
	
	protected def getDocumentAccess(String uri, String requiredStateId) {
		try {
			val document = session.get(XtextWebDocument -> uri, [
				resourceHandler.get(uri, new ServiceContextAdapter(session))
			])
			return documentAccessFactory.create(document, requiredStateId, false)
		} catch (IOException ioe) {
			throw new InvalidMessageException('The requested resource was not found.')
		}
	}
	
	override codeAction(CodeActionParams params) {
		throw new InvalidMessageException("Method not supported.")
	}
	
	override codeLens(CodeLensParams params) {
		throw new InvalidMessageException("Method not supported.")
	}
	
	override completion(TextDocumentPositionParams params) {
		// Support protocol version 1.0
		val document = params.textDocument?.documentAccess ?: getDocumentAccess(params.uri, null)
		val offset = document.getOffset(params.position)
		val selection = new TextRegion(offset, 0)
		CompletableFuture.supplyAsync[
			val proposals = contentAssistService.createProposals(document, selection, offset, ContentAssistService.DEFAULT_PROPOSALS_LIMIT)
			val result = new CompletionListImpl
			result.items = proposals.entries.map[ entry |
				new CompletionItemImpl => [
					label = entry.label ?: entry.proposal
					detail = entry.description
					insertText = entry.proposal
				]
			]
			return result
		]
	}
	
	override definition(TextDocumentPositionParams params) {
		throw new InvalidMessageException("Method not supported.")
	}
	
	override didChange(DidChangeTextDocumentParams params) {
		// Support protocol version 1.0
		val document = params.textDocument?.documentAccess ?: getDocumentAccess(params.uri, null)
		document.modify[ it, cancelIndicator |
			dirty = true
			for (change : params.contentChanges) {
				val offset = getOffset(change.range.start)
				updateText(change.text, offset, change.rangeLength)
			}
			if (params.textDocument !== null && params.textDocument.version != 0)
				resource.modificationStamp = params.textDocument.version
			return null
		]
	}
	
	override didClose(DidCloseTextDocumentParams params) {
		session.remove(XtextWebDocument -> params.textDocument.uri)
	}
	
	override didOpen(DidOpenTextDocumentParams params) {
		var XtextWebDocumentAccess document
		val Wrapper<String> textContent = new Wrapper
		if (params.textDocument !== null) {
			document = getDocumentAccess(params.textDocument)
			textContent.set = params.textDocument.text
		} else {
			// Support protocol version 1.0
			document = getDocumentAccess(params)
			textContent.set = params.text
		}
		if (textContent !== null) {
			document.modify[ it, cancelIndicator |
				text = textContent.get
				if (params.textDocument !== null && params.textDocument.version != 0)
					resource.modificationStamp = params.textDocument.version
				return null
			]
		}
	}
	
	override didSave(DidSaveTextDocumentParams params) {
		val document = getDocumentAccess(params.textDocument)
		document.modify[ it, cancelIndicator |
			dirty = false
			return null
		]
	}
	
	override documentHighlight(TextDocumentPositionParams params) {
		throw new InvalidMessageException("Method not supported.")
	}
	
	override documentSymbol(DocumentSymbolParams params) {
		throw new InvalidMessageException("Method not supported.")
	}
	
	override formatting(DocumentFormattingParams params) {
		throw new InvalidMessageException("Method not supported.")
	}
	
	override hover(TextDocumentPositionParams params) {
		throw new InvalidMessageException("Method not supported.")
	}
	
	override onPublishDiagnostics(Consumer<PublishDiagnosticsParams> callback) {
		synchronized (diagnosticsCallbacks) {
			diagnosticsCallbacks.add(callback)
		}
	}
	
	def void publishDiagnostics(String uri, List<DiagnosticImpl> diagnostics) {
		val params = new PublishDiagnosticsParamsImpl
		params.uri = uri
		params.diagnostics = diagnostics
		val callbacks = synchronized (diagnosticsCallbacks) {
			new ArrayList(diagnosticsCallbacks)
		}
		for (c : callbacks) {
			c.accept(params)
		}
	}
	
	override onTypeFormatting(DocumentOnTypeFormattingParams params) {
		throw new InvalidMessageException("Method not supported.")
	}
	
	override rangeFormatting(DocumentRangeFormattingParams params) {
		throw new InvalidMessageException("Method not supported.")
	}
	
	override references(ReferenceParams params) {
		throw new InvalidMessageException("Method not supported.")
	}
	
	override rename(RenameParams params) {
		throw new InvalidMessageException("Method not supported.")
	}
	
	override resolveCodeLens(CodeLens unresolved) {
		throw new InvalidMessageException("Method not supported.")
	}
	
	override resolveCompletionItem(CompletionItem unresolved) {
		throw new InvalidMessageException("Method not supported.")
	}
	
	override signatureHelp(TextDocumentPositionParams params) {
		throw new InvalidMessageException("Method not supported.")
	}
	
	override onLogMessage(Consumer<MessageParams> callback) {
		synchronized (logMessageCallbacks) {
			logMessageCallbacks.add(callback)
		}
	}
	
	override onShowMessage(Consumer<MessageParams> callback) {
		synchronized (showMessageCallbacs) {
			showMessageCallbacs.add(callback)
		}
	}
	
	override onShowMessageRequest(Consumer<ShowMessageRequestParams> callback) {
		synchronized (showMessageRequestCallbacs) {
			showMessageRequestCallbacs.add(callback)
		}
	}
	
	override didChangeConfiguraton(DidChangeConfigurationParams params) {
		// Method not supported
	}
	
	override didChangeWatchedFiles(DidChangeWatchedFilesParams params) {
		// Method not supported
	}
	
	override symbol(WorkspaceSymbolParams params) {
		throw new InvalidMessageException("Method not supported.")
	}
	
}