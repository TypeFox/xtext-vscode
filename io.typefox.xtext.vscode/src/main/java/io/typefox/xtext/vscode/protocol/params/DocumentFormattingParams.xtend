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
import io.typefox.xtext.vscode.protocol.options.FormattingOptions

/**
 * The document formatting resquest is sent from the server to the client to format a whole document.
 */
@Accessors
@ToString
class DocumentFormattingParams {
	
	/**
	 * The document to format.
	 */
	TextDocumentIdentifier textDocument
	
	/**
	 * The format options
	 */
	FormattingOptions options
	
}