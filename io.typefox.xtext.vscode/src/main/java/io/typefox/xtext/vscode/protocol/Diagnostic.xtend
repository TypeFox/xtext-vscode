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
 * Represents a diagnostic, such as a compiler error or warning. Diagnostic objects are only valid in the scope of a resource.
 */
@Accessors
@ToString
class Diagnostic {
	
	/**
	 * Reports an error.
	 */
	public static val SEVERITY_ERROR = 1
	
	/**
	 * Reports a warning.
	 */
	public static val SEVERITY_WARNING = 2
	
	/**
	 * Reports an information.
	 */
	public static val SEVERITY_INFO = 3
	
	/**
	 * Reports a hint.
	 */
	public static val SEVERITY_HINT = 5
	
	/**
	 * The range at which the message applies
	 */
	Range range
	
	/**
	 * The diagnostic's severity. Can be omitted. If omitted it is up to the client to interpret diagnostics as error,
	 * warning, info or hint.
	 */
	Integer severity
	
	/**
	 * The diagnostic's code. Can be omitted.
	 */
	String code
	
	/**
	 * A human-readable string describing the source of this diagnostic, e.g. 'typescript' or 'super lint'.
	 */
	String source
	
	/**
	 * The diagnostic's message.
	 */
	String message
	
}