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
 * Format document on type options
 */
@Accessors
@ToString
class DocumentOnTypeFormattingOptions {
	
	/**
	 * A character on which formatting should be triggered, like `}`.
	 */
	String firstTriggerCharacter
	
	/**
	 * More trigger characters.
	 */
	String[] moreTriggerCharacter
	
}