/*******************************************************************************
 * Copyright (c) 2016 TypeFox GmbH (http://www.typefox.io) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package io.typefox.xtext.vscode

import io.typefox.lsapi.Message
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.eclipse.xtext.web.server.ISession

/**
 * Provides the parameters and meta data of a service request.
 */
interface IServiceContext {
	
	/**
	 * Returns the message received from the client.
	 */
	def Message getMessage()
	
	/**
	 * Returns a session into which information can be stored across multiple requests from
	 * the same client. If a session does not exist yet, one is created.
	 */
	def ISession getSession()
	
	@FinalFieldsConstructor
	@Accessors
	static class Impl implements IServiceContext {
		
		val Message message
		
		val ISession session
		
	}
	
}
