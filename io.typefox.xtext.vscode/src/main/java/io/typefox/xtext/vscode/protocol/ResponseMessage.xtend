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
 * Response Message send as a result of a request.
 */
@Accessors
@ToString
class ResponseMessage extends Message {
	
	/**
	 * The request id.
	 */
	String id
	
	/**
	 * The result of a request. This can be omitted in the case of an error.
	 */
	Object result
	
	/**
	 * The error object in case a request fails.
	 */
	ResponseError error
	
}