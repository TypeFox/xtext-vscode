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
 * The initialize request is sent as the first request from the client to the server.
 */
@Accessors
@ToString
class InitializeParams {
	
	/**
	 * The process Id of the parent process that started the server.
	 */
	int processId
	
	/**
	 * The rootPath of the workspace. Is null if no folder is open.
	 */
	String rootPath
	
	/**
	 * The capabilities provided by the client (editor)
	 */
	Object capabilities
	
}