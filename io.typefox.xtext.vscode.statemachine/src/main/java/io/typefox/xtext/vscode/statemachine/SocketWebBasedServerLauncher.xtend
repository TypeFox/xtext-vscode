/*******************************************************************************
 * Copyright (c) 2016 TypeFox GmbH (http://www.typefox.io) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package io.typefox.xtext.vscode.statemachine

import com.google.inject.Provider
import io.typefox.xtext.vscode.VSCodeJsonAdapter
import java.io.IOException
import java.io.PrintWriter
import java.net.InetSocketAddress
import java.nio.channels.AsynchronousServerSocketChannel
import java.nio.channels.AsynchronousSocketChannel
import java.nio.channels.Channels
import java.nio.channels.CompletionHandler
import java.util.List
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class SocketWebBasedServerLauncher {
	
	def static void main(String[] args) {
		val List<ExecutorService> executorServices = newArrayList
		var AsynchronousServerSocketChannel serverSocket
		try {
			val Provider<ExecutorService> executorServiceProvider = [Executors.newCachedThreadPool => [executorServices += it]]
			val resourceBaseProvider = new VSCodeJsonAdapter.ResourceBaseProvider
			val injector = new StatemachineWebSetup(executorServiceProvider, resourceBaseProvider).createInjectorAndDoEMFRegistration()
			val server = injector.getInstance(VSCodeJsonAdapter)
			server.resourceBaseProvider = resourceBaseProvider
			server.errorLog = new PrintWriter(System.err)
			server.messageLog = new PrintWriter(System.out)
			
			serverSocket = AsynchronousServerSocketChannel.open()
			val address = new InetSocketAddress('localhost', 5007)
			serverSocket.bind(address)
			println('Listening to ' + address)
			serverSocket.accept(null, new CompletionHandler<AsynchronousSocketChannel, Object> {
				
				override completed(AsynchronousSocketChannel channel, Object attachment) {
					val in = Channels.newInputStream(channel)
					val out = Channels.newOutputStream(channel)
					println('Connection accepted')
					
					server.connect(in, out)
					server.join()
					
					channel.close()
					println('Connection closed')
				}
				
				override failed(Throwable exc, Object attachment) {
					exc.printStackTrace()
				}
			})
			while (!server.exitRequested) {
				Thread.sleep(2000)
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