/*******************************************************************************
 * Copyright (c) 2016 TypeFox GmbH (http://www.typefox.io) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package io.typefox.xtext.vscode

import com.google.gson.Gson
import com.google.gson.JsonObject
import com.google.gson.JsonParser
import io.typefox.xtext.vscode.protocol.CodeLens
import io.typefox.xtext.vscode.protocol.CompletionItem
import io.typefox.xtext.vscode.protocol.Message
import io.typefox.xtext.vscode.protocol.NotificationMessage
import io.typefox.xtext.vscode.protocol.RequestMessage
import io.typefox.xtext.vscode.protocol.params.CodeActionParams
import io.typefox.xtext.vscode.protocol.params.CodeLensParams
import io.typefox.xtext.vscode.protocol.params.DidChangeConfigurationParams
import io.typefox.xtext.vscode.protocol.params.DidChangeTextDocumentParams
import io.typefox.xtext.vscode.protocol.params.DidChangeWatchedFilesParams
import io.typefox.xtext.vscode.protocol.params.DidCloseTextDocumentParams
import io.typefox.xtext.vscode.protocol.params.DidOpenTextDocumentParams
import io.typefox.xtext.vscode.protocol.params.DocumentOnTypeFormattingParams
import io.typefox.xtext.vscode.protocol.params.DocumentRangeFormattingParams
import io.typefox.xtext.vscode.protocol.params.DocumentSymbolParams
import io.typefox.xtext.vscode.protocol.params.InitializeParams
import io.typefox.xtext.vscode.protocol.params.ReferenceParams
import io.typefox.xtext.vscode.protocol.params.RenameParams
import io.typefox.xtext.vscode.protocol.params.TextDocumentPositionParams
import io.typefox.xtext.vscode.protocol.params.WorkspaceSymbolParams

class VSCodeJsonHandler {
	
	val jsonParser = new JsonParser
	val gson = new Gson
	
	def Message parseMessage(String input) {
		val json = jsonParser.parse(input).asJsonObject
		val idElement = json.get('id')
		if (idElement !== null)
			parseRequest(json, idElement.asString)
		else
			parseNotification(json)
	}
	
	protected def RequestMessage parseRequest(JsonObject json, String requestId) {
		val result = new RequestMessage
		result.id = requestId
		try {
			result.method = json.get('method').asString
			val params = json.get('params')?.asJsonObject
			if (params !== null) {
				switch result.method {
					case 'initialize':
						result.params = gson.fromJson(params, InitializeParams)
					case 'textDocument/completion',
					case 'textDocument/hover',
					case 'textDocument/signatureHelp',
					case 'textDocument/definition',
					case 'textDocument/documentHighlight':
						result.params = gson.fromJson(params, TextDocumentPositionParams)
					case 'completionItem/resolve':
						result.params = gson.fromJson(params, CompletionItem)
					case 'textDocument/references':
						result.params = gson.fromJson(params, ReferenceParams)
					case 'textDocument/documentSymbol':
						result.params = gson.fromJson(params, DocumentSymbolParams)
					case 'workspace/symbol':
						result.params = gson.fromJson(params, WorkspaceSymbolParams)
					case 'textDocument/codeAction':
						result.params = gson.fromJson(params, CodeActionParams)
					case 'textDocument/codeLens':
						result.params = gson.fromJson(params, CodeLensParams)
					case 'codeLens/resolve':
						result.params = gson.fromJson(params, CodeLens)
					case 'textDocument/rangeFormatting':
						result.params = gson.fromJson(params, DocumentRangeFormattingParams)
					case 'textDocument/onTypeFormatting':
						result.params = gson.fromJson(params, DocumentOnTypeFormattingParams)
					case 'textDocument/rename':
						result.params = gson.fromJson(params, RenameParams)
				}
			}
		} catch (Exception e) {
			throw new InvalidRequestException("Could not parse request: " + e.message, requestId, e)
		}
		return result
	}
	
	protected def NotificationMessage parseNotification(JsonObject json) {
		val result = new NotificationMessage
		try {
			result.method = json.get('method').asString
			val params = json.get('params')?.asJsonObject
			if (params !== null) {
				switch result.method {
					case 'workspace/didChangeConfiguration':
						result.params = gson.fromJson(params, DidChangeConfigurationParams)
					case 'textDocument/didOpen':
						result.params = gson.fromJson(params, DidOpenTextDocumentParams)
					case 'textDocument/didChange':
						result.params = gson.fromJson(params, DidChangeTextDocumentParams)
					case 'textDocument/didClose':
						result.params = gson.fromJson(params, DidCloseTextDocumentParams)
					case 'workspace/didChangeWatchedFiles':
						result.params = gson.fromJson(params, DidChangeWatchedFilesParams)
				}
			}
		} catch (Exception e) {
			throw new InvalidRequestException("Could not parse notification: " + e.message, null, e)
		}
		return result
	}
	
	def String serialize(Message message) {
		gson.toJson(message)
	}
	
}