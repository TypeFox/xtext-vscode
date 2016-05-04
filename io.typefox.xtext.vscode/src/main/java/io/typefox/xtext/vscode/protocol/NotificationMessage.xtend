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
 * A notification message. A processed notification message must not send a response back. They work like events.
 */
@Accessors
@ToString
class NotificationMessage extends Message {
	
	/**
	 * The method to be invoked.
	 */
	String method
	
	/**
	 * The notification's params.
	 */
	Object params
	
}