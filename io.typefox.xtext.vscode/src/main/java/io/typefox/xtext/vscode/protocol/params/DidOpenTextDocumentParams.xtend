/*******************************************************************************
 * Copyright (c) 2016 TypeFox GmbH (http://www.typefox.io) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package io.typefox.xtext.vscode.protocol.params

import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.ToString
import io.typefox.xtext.vscode.protocol.TextDocumentIdentifier
import io.typefox.xtext.vscode.protocol.TextDocumentItem

/**
 * The document open notification is sent from the client to the server to signal newly opened text documents.
 * The document's truth is now managed by the client and the server must not try to read the document's truth using
 * the document's uri.
 */
@Accessors
@ToString
class DidOpenTextDocumentParams extends TextDocumentIdentifier {
	
	/**
	 * The document that was opened.
	 */
	TextDocumentItem textDocument
	
	/**
	 * Legacy property to support protocol version 1.0 requests.
	 */
	@Deprecated
	String text
	
}