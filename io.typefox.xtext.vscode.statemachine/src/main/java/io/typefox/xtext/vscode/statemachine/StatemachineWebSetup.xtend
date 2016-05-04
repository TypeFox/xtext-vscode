/*******************************************************************************
 * Copyright (c) 2016 TypeFox GmbH (http://www.typefox.io) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package io.typefox.xtext.vscode.statemachine

import com.google.inject.Guice
import com.google.inject.Injector
import com.google.inject.Module
import com.google.inject.Provider
import com.google.inject.util.Modules
import java.util.concurrent.ExecutorService
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.eclipse.xtext.web.server.persistence.IResourceBaseProvider
import org.xtext.example.statemachine.StatemachineRuntimeModule
import org.xtext.example.statemachine.StatemachineStandaloneSetup

/** 
 * Initialization support for running Xtext languages in web applications.
 */
@FinalFieldsConstructor
class StatemachineWebSetup extends StatemachineStandaloneSetup {

	val Provider<ExecutorService> executorServiceProvider
	
	val IResourceBaseProvider resourceBaseProvider

	override Injector createInjector() {
		var Module runtimeModule = new StatemachineRuntimeModule()
		var Module webModule = new StatemachineWebModule(executorServiceProvider, resourceBaseProvider)
		return Guice.createInjector(Modules.^override(runtimeModule).with(webModule))
	}
	
}
