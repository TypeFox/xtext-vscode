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
 * The Completion request is sent from the client to the server to compute completion items at a given cursor position.
 * Completion items are presented in the IntelliSense user interface. If computing complete completion items is expensive
 * servers can additional provide a handler for the resolve completion item request. This request is send when a
 * completion item is selected in the user interface.
 */
@Accessors
@ToString
class CompletionItem {
	
	public static val KIND_TEXT = 1
	public static val KIND_METHOD = 2
	public static val KIND_FUNCTION = 3
	public static val KIND_CONSTRUCTOR = 4
	public static val KIND_FIELD = 5
	public static val KIND_VARIABLE = 6
	public static val KIND_CLASS = 7
	public static val KIND_INTERFACE = 8
	public static val KIND_MODULE = 9
	public static val KIND_PROPERTY = 10
	public static val KIND_UNIT = 11
	public static val KIND_VALUE = 12
	public static val KIND_ENUM = 13
	public static val KIND_KEYWORD = 14
	public static val KIND_SNIPPET = 15
	public static val KIND_COLOR = 16
	public static val KIND_FILE = 17
	public static val KIND_REFERENCE = 18
	
	/**
	 * The label of this completion item. By default also the text that is inserted when selecting this completion.
	 */
	String label
	
	/**
	 * The kind of this completion item. Based of the kind an icon is chosen by the editor.
	 */
	Integer kind
	
	/**
	 * A human-readable string with additional information about this item, like type or symbol information.
	 */
	String detail
	
	/**
	 * A human-readable string that represents a doc-comment.
	 */
	String documentation
	
	/**
	 * A string that shoud be used when comparing this item with other items. When `falsy` the label is used.
	 */
	String sortText
	
	/**
	 * A string that should be used when filtering a set of completion items. When `falsy` the label is used.
	 */
	String filterText
	
	/**
	 * A string that should be inserted a document when selecting this completion. When `falsy` the label is used.
	 */
	String insertText
	
	/**
	 * An edit which is applied to a document when selecting this completion. When an edit is provided the value of
     * insertText is ignored.
	 */
	TextEdit textEdit
	
	/**
	 * An data entry field that is preserved on a completion item between a completion and a completion resolve request.
	 */
	Object data
	
}