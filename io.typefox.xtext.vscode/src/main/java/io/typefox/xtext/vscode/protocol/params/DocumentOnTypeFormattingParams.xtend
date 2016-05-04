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
import io.typefox.xtext.vscode.protocol.Position

/**
 * The document on type formatting request is sent from the client to the server to format parts of the document during typing.
 */
@Accessors
@ToString
class DocumentOnTypeFormattingParams extends DocumentFormattingParams {
	
	/**
	 * The position at which this request was send.
	 */
	Position position
	
	/**
	 * The character that has been typed.
	 */
	String ch
	
}