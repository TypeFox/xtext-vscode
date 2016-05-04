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
 * Represents information about programming constructs like variables, classes, interfaces etc.
 */
@Accessors
@ToString
class SymbolInformation {
	
	public static val KIND_FILE = 1
	public static val KIND_MODULE = 2
	public static val KIND_NAMESPACE = 3
	public static val KIND_PACKAGE = 4
	public static val KIND_CLASS = 5
	public static val KIND_METHOD = 6
	public static val KIND_PROPERTY = 7
	public static val KIND_FIELD = 8
	public static val KIND_CONSTRUCTOR = 9
	public static val KIND_ENUM = 10
	public static val KIND_INTERFACE = 11
	public static val KIND_FUNCTION = 12
	public static val KIND_VARIABLE = 13
	public static val KIND_CONSTANT = 14
	public static val KIND_STRING = 15
	public static val KIND_NUMBER = 16
	public static val KIND_BOOLEAN = 17
	public static val KIND_ARRAY = 18
	
	/**
	 * The name of this symbol.
	 */
	String name
	
	/**
	 * The kind of this symbol.
	 */
	int kind
	
	/**
	 * The location of this symbol.
	 */
	Location location
	
	/**
	 * The name of the symbol containing this symbol.
	 */
	String container
	
}