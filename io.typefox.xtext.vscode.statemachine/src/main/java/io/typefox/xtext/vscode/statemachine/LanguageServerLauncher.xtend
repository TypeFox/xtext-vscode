/*******************************************************************************
 * Copyright (c) 2016 TypeFox GmbH (http://www.typefox.io) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package io.typefox.xtext.vscode.statemachine

import com.google.inject.Provider
import io.typefox.xtext.vscode.LanguageServer
import java.io.IOException
import java.io.PrintWriter
import java.util.List
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class LanguageServerLauncher {
	
	def static void main(String[] args) {
		val List<ExecutorService> executorServices = newArrayList
		var PrintWriter log
		try {
			log = new PrintWriter('LanguageServer.log')
			val Provider<ExecutorService> executorServiceProvider = [Executors.newCachedThreadPool => [executorServices += it]]
			val resourceBaseProvider = new LanguageServer.ResourceBaseProvider
			val injector = new StatemachineWebSetup(executorServiceProvider, resourceBaseProvider).createInjectorAndDoEMFRegistration()
			val server = injector.getInstance(LanguageServer)
			server.log = log
			server.resourceBaseProvider = resourceBaseProvider
			
			server.serve(System.in, System.out)
			
		} catch (Throwable t) {
			t.printStackTrace()
		} finally {
			executorServices.forEach[shutdown()]
			try {
				log?.close()
			} catch (IOException e) {}
		}
	}
	
}