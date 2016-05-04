/*******************************************************************************
 * Copyright (c) 2016 TypeFox GmbH (http://www.typefox.io) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.xtext.example.statemachine.validation

import org.eclipse.xtext.validation.Check
import org.xtext.example.statemachine.statemachine.Command
import org.xtext.example.statemachine.statemachine.Event
import org.xtext.example.statemachine.statemachine.InputSignal
import org.xtext.example.statemachine.statemachine.OutputSignal

import static org.xtext.example.statemachine.statemachine.StatemachinePackage.Literals.*

/**
 * This class contains custom validation rules. 
 *
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class StatemachineValidator extends AbstractStatemachineValidator {
	
	@Check
	def checkEventUsesInputSignal(Event event) {
		if (event.signal !== null && !event.signal.eIsProxy && !(event.signal instanceof InputSignal)) {
			error('Only input signals are allowed for read access.', event, EVENT__SIGNAL)
		}
	}
	
	@Check
	def checkCommandUsesOutputSignal(Command command) {
		if (command.signal !== null && !command.signal.eIsProxy && !(command.signal instanceof OutputSignal)) {
			error('Only output signals are allowed for write access.', command, COMMAND__SIGNAL)
		}
	}
	
}
