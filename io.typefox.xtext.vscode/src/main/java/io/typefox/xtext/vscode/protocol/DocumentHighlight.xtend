/*******************************************************************************
 * Copyright (c) 2016 TypeFox GmbH (http://www.typefox.io) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package io.typefox.xtext.vscode.protocol

import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.ToString

/**
 * A document highlight is a range inside a text document which deserves special attention. Usually a document highlight
 * is visualized by changing the background color of its range.
 */
@Accessors
@ToString
class DocumentHighlight {
	
	/**
	 * A textual occurrance.
	 */
	public static val KIND_TEXT = 1
	
	/**
	 * Read-access of a symbol, like reading a variable.
	 */
	public static val KIND_READ = 2
	
	/**
	 * Write-access of a symbol, like writing to a variable.
	 */
	public static val KIND_WRITE = 3
	
	/**
	 * The range this highlight applies to.
	 */
	Range range
	
	/**
	 * The highlight kind, default is KIND_TEXT.
	 */
	Integer kind
	
}