/*******************************************************************************
 * Copyright (c) 2016 TypeFox GmbH (http://www.typefox.io) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package io.typefox.xtext.vscode.protocol.options

import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.ToString

@Accessors
@ToString
class ServerCapabilities {
	
	/**
	 * Documents should not be synced at all.
	 */
	public static val SYNC_NONE = 0
	
	/**
	 * Documents are synced by always sending the full content of the document.
	 */
	public static val SYNC_FULL = 1
	
	/**
	 * Documents are synced by sending the full content on open. After that only incremental
     * updates to the document are send.
	 */
	public static val SYNC_INCREMENTAL = 2
	
	/**
	 * Defines how text documents are synced.
	 */
	Integer textDocumentSync
	
	/**
	 * The server provides hover support.
	 */
	Boolean hoverProvider
	
	/**
	 * The server provides completion support.
	 */
	CompletionOptions completionProvider
	
	/**
	 * The server provides signature help support.
	 */
	SignatureHelpOptions signatureHelpProvider
	
	/**
	 * The server provides goto definition support.
	 */
	Boolean definitionProvider
	
	/**
	 * The server provides find references support.
	 */
	Boolean referencesProvider
	
	/**
	 * The server provides document highlight support.
	 */
	Boolean documentHighlightProvider
	
	/**
	 * The server provides document symbol support.
	 */
	Boolean documentSymbolProvider
	
	/**
	 * The server provides workspace symbol support.
	 */
	Boolean workspaceSymbolProvider
	
	/**
	 * The server provides code actions.
	 */
	Boolean codeActionProvider
	
	/**
	 * The server provides code lens.
	 */
	CodeLensOptions codeLensProvider
	
	/**
	 * The server provides document formatting.
	 */
	Boolean documentFormattingProvider
	
	/**
	 * The server provides document range formatting.
	 */
	Boolean documentRangeFormattingProvider
	
	/**
	 * The server provides document formatting on typing.
	 */
	DocumentOnTypeFormattingOptions documentOnTypeFormattingProvider
	
	/**
	 * The server provides rename support.
	 */
	Boolean renameProvider
	
}