/*******************************************************************************
 * Copyright (c) 2016 TypeFox GmbH (http://www.typefox.io) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.xtext.example.statemachine


/**
 * Initialization support for running Xtext languages without Equinox extension registry.
 */
class StatemachineStandaloneSetup extends StatemachineStandaloneSetupGenerated {

	def static void doSetup() {
		new StatemachineStandaloneSetup().createInjectorAndDoEMFRegistration()
	}
}
