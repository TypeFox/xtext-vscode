/*******************************************************************************
 * Copyright (c) 2016 TypeFox GmbH (http://www.typefox.io) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package io.typefox.xtext.vscode

import io.typefox.xtext.vscode.protocol.Position
import io.typefox.xtext.vscode.protocol.Range
import org.eclipse.xtext.web.server.model.IXtextWebDocument
import org.eclipse.xtext.web.server.model.XtextWebDocumentAccess

class DocumentPositionHelper {
	
	def int getOffset(XtextWebDocumentAccess document, Position position) {
		document.readOnly[it, cancelIndicator | getOffset(position)]
	}
	
	def int getOffset(IXtextWebDocument document, Position position) {
		var row = 0
		var col = 0
		var offset = 0
		val text = document.text
		while (offset < text.length && (row < position.line || col < position.character)) {
			val c = text.charAt(offset)
			if (c.matches('\n')) {
				row++
				col = 0
			} else {
				col++
			}
			offset++
		}
		return offset
	}
	
	def Range getRange(XtextWebDocumentAccess document, int offset, int length) {
		document.readOnly[it, cancelIndicator | getRange(offset, length)]
	}
	
	def Range getRange(IXtextWebDocument document, int offset, int length) {
		if (length < 0)
			throw new IllegalArgumentException('Length must not be negative.')
		var row = 0
		var col = 0
		val text = document.text
		val endOffset = Math.min(offset + length, text.length - 1)
		val result = new Range
		for (var i = 0; i < endOffset; i++) {
			if (i == offset) {
				result.start = new Position
				result.start.line = row
				result.start.character = col
			}
			val c = text.charAt(i)
			if (c.matches('\n')) {
				row++
				col = 0
			} else {
				col++
			}
		}
		result.end = new Position
		result.end.line = row
		result.end.character = col
		if (result.start === null)
			result.start = result.end
		return result
	}
	
	private def matches(char c1, char c2) {
		c1 == c2
	}
	
}