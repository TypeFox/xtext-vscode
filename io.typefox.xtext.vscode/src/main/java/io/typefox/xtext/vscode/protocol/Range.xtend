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
 * A range in a text document expressed as (zero-based) start and end positions.
 */
@Accessors
@ToString
class Range {
	
	/**
	 * The range's start position
	 */
	Position start
	
	/**
	 * The range's end position
	 */
	Position end
	
}