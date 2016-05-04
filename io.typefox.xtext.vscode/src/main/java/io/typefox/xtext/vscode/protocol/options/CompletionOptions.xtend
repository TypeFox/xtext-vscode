/*******************************************************************************
 * Copyright (c) 2016 TypeFox GmbH (http://www.typefox.io) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package io.typefox.xtext.vscode.protocol.options

import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.ToString

/**
 * Completion options.
 */
@Accessors
@ToString
class CompletionOptions {
	
	/**
	 * The server provides support to resolve additional information for a completion item.
	 */
	boolean resolveProvider
	
	/**
	 * The characters that trigger completion automatically.
	 */
	String[] triggerCharacters
	
}
