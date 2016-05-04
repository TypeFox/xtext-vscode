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

@Accessors
@ToString
class ResponseError {
	
	public static val PARSE_ERROR = -32700
	public static val INVALID_REQUEST = -32600
	public static val METHOD_NOT_FOUND = -32601
	public static val INVALID_PARAMS = -32602
	public static val INTERNAL_ERROR = -32603
	public static val SERVER_ERROR_START = -32099
	public static val SERVER_ERROR_END = -32000
	
	/**
	 * A number indicating the error type that occured.
	 */
	int code
	
	/**
	 * A string providing a short decription of the error.
	 */
	String message
	
	/**
	 * A Primitive or Structured value that contains additional information about the error. Can be omitted.
	 */
	Object data
	
}