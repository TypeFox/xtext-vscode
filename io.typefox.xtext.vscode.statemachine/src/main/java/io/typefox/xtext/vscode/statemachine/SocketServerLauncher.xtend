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
import java.net.InetSocketAddress
import java.nio.channels.Channels
import java.nio.channels.ServerSocketChannel
import java.util.List
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class SocketServerLauncher {
	
	def static void main(String[] args) {
		val List<ExecutorService> executorServices = newArrayList
		var ServerSocketChannel serverSocket
		try {
			val Provider<ExecutorService> executorServiceProvider = [Executors.newCachedThreadPool => [executorServices += it]]
			val resourceBaseProvider = new LanguageServer.ResourceBaseProvider
			val injector = new StatemachineWebSetup(executorServiceProvider, resourceBaseProvider).createInjectorAndDoEMFRegistration()
			val server = injector.getInstance(LanguageServer)
			server.log = new PrintWriter(System.out)
			server.resourceBaseProvider = resourceBaseProvider
			
			serverSocket = ServerSocketChannel.open()
			val address = new InetSocketAddress('localhost', 5007)
			serverSocket.bind(address)
			while (!server.exitRequested) {
				println('Listening to ' + address)
				val channel = serverSocket.accept()
				val in = Channels.newInputStream(channel)
				val out = Channels.newOutputStream(channel)
				println('Connection accepted')
				server.serve(in, out)
				channel.close()
				println('Connection closed')
			}
			
		} catch (Throwable t) {
			t.printStackTrace()
		} finally {
			executorServices.forEach[shutdown()]
			if (serverSocket !== null) {
				try {
					serverSocket.close()
				} catch (IOException e) {}
			}
		}
	}
	
}