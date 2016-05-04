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
import io.typefox.xtext.vscode.protocol.Diagnostic

/**
 * Diagnostics notification are sent from the server to the client to signal results of validation runs.
 */
@Accessors
@ToString
class PublishDiagnosticsParams {
	
	/**
	 * The URI for which diagnostic information is reported.
	 */
	String uri
	
	/**
	 * An array of diagnostic information items.
	 */
	Diagnostic[] diagnostics
	
}