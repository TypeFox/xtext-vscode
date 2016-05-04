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

/**
 * The show message notification is sent from a server to a client to ask the client to display a particular message
 * in the user interface.
 * 
 * The log message notification is send from the server to the client to ask the client to log a particular message.
 */
@Accessors
@ToString
class MessageParams {
	
	/**
	 * An error message.
	 */
	public static val TYPE_ERROR = 1
	
	/**
	 * A warning message.
	 */
	public static val TYPE_WARNING = 2
	
	/**
	 * An information message.
	 */
	public static val TYPE_INFO = 3
	
	/**
	 * A log message.
	 */
	public static val TYPE_LOG = 1
	
	/**
	 * The message type.
	 */
	int type
	
	/**
	 * The actual message.
	 */
	String message
	
}