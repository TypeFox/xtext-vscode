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
 * An event describing a change to a text document. If range and rangeLength are omitted the new text is considered
 * to be the full content of the document.
 */
@Accessors
@ToString
class TextDocumentContentChangeEvent {
	
	/**
	 * The range of the document that changed.
	 */
	Range range
	
	/**
	 * The length of the range that got replaced.
	 */
	Integer rangeLength
	
	/**
	 * The new text of the document.
	 */
	String text
	
}