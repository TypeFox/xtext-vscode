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
 * An event describing a file change.
 */
@Accessors
@ToString
class FileEvent {
	
	/**
	 * The file got created.
	 */
	public static val TYPE_CREATED = 1
	
	/**
	 * The file got changed.
	 */
	public static val TYPE_CHANGED = 2
	
	/**
	 * The file got deleted.
	 */
	public static val TYPE_DELETED = 3
	
	/**
	 * The file's uri.
	 */
	String uri
	
	/**
	 * The change type.
	 */
	int type
	
}