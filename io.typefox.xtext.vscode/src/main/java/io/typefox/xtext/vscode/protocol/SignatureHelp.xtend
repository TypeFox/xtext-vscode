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
 * Signature help represents the signature of something callable. There can be multiple signature but only one
 * active and only one active parameter.
 */
@Accessors
@ToString
class SignatureHelp {
	
	/**
	 * One or more signatures.
	 */
	SignatureInformation[] signatures
	
	/**
	 * The active signature.
	 */
	Integer activeSignature
	
	/**
	 * The active parameter of the active signature.
	 */
	Integer activeParameter
	
}