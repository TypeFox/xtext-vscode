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
 * A request message to decribe a request between the client and the server. Every processed request must send a response back
 * to the sender of the request.
 */
@Accessors
@ToString
class RequestMessage extends Message {
	
	/**
	 * The request id.
	 */
	String id
	
	/**
	 * The method to be invoked.
	 */
	String method
	
	/**
	 * The method's params.
	 */
	Object params
	
}