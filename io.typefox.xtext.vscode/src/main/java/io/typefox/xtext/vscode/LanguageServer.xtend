/*******************************************************************************
 * Copyright (c) 2016 TypeFox GmbH (http://www.typefox.io) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package io.typefox.xtext.vscode

import com.google.inject.Inject
import io.typefox.xtext.vscode.protocol.Message
import io.typefox.xtext.vscode.protocol.RequestMessage
import io.typefox.xtext.vscode.protocol.ResponseError
import io.typefox.xtext.vscode.protocol.ResponseMessage
import io.typefox.xtext.vscode.protocol.params.InitializeParams
import java.io.File
import java.io.IOException
import java.io.InputStream
import java.io.InputStreamReader
import java.io.OutputStream
import java.io.PrintWriter
import java.io.UnsupportedEncodingException
import org.eclipse.emf.common.util.URI
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.web.server.persistence.IResourceBaseProvider
import io.typefox.xtext.vscode.protocol.NotificationMessage

class LanguageServer {
	
	public static val JSONRPC_VERSION = '2.0'
	
	static val CONTENT_LENGTH = 'Content-Length'
	static val CONTENT_TYPE = 'Content-Type'
	
	@Inject VSCodeJsonHandler jsonHandler
	
	@Inject VSCodeServiceDispatcher serviceDispatcher
	
	val session = new HashMapSession
	
	@Accessors(PUBLIC_GETTER)
	boolean exitRequested
	
	@Accessors
	ResourceBaseProvider resourceBaseProvider
	
	@Accessors
	PrintWriter log
	
	private def logException(Throwable throwable) {
		try {
			if (log !== null) {
				throwable.printStackTrace(log)
				log.flush()
			}
		} catch (IOException e) {
			throwable.printStackTrace()
		}
	}
	
	private def logMessage(String title, String content) {
		try {
			if (log !== null) {
				log.println(title)
				log.println('\t' + content)
				log.flush()
			}
		} catch (IOException e) {
			e.printStackTrace()
		}
	}
	
	def serve(InputStream in, OutputStream out) throws IOException {
		var StringBuilder builder
		var newLine = false
		var contentLength = -1
		var charset = 'UTF-8'
		var keepServing = true
		var c = in.read
		while (keepServing && c != -1) {
			if (c.matches('\n')) {
				if (newLine) {
					if (contentLength < 0)
						throw new IllegalStateException('Missing header ' + CONTENT_LENGTH)
					val reader = new InputStreamReader(in, charset)
					val buffer = newCharArrayOfSize(contentLength)
					val charsRead = reader.read(buffer, 0, contentLength)
					try {
						if (charsRead < 0)
							keepServing = false
						else
							keepServing = handleRequest(new String(buffer), out, charset)
					} catch (UnsupportedEncodingException e) {
						logException(e)
					}
					contentLength = -1
				} else if (builder !== null) {
					val line = builder.toString
					val sepIndex = line.indexOf(':')
					if (sepIndex >= 0) {
						val key = line.substring(0, sepIndex).trim
						switch key {
							case CONTENT_LENGTH:
								try {
									contentLength = Integer.parseInt(line.substring(sepIndex + 1).trim)
								} catch (NumberFormatException e) {
									logException(e)
								}
							case CONTENT_TYPE: {
								val charsetIndex = line.indexOf('charset=')
								if (charsetIndex >= 0)
									charset = line.substring(charsetIndex + 8).trim
							}
						}
					}
					builder = null
				}
				newLine = true
			} else if (!c.matches('\r')) {
				if (builder === null)
					builder = new StringBuilder
				builder.append(c as char)
				newLine = false
			}
			c = in.read
		}
	}
	
	private def matches(int c1, char c2) {
		c1 == c2
	}
	
	protected def boolean handleRequest(String content, OutputStream out, String charset)
			throws IOException {
		var Message response
		try {
			val request = jsonHandler.parseMessage(content)
			if (request instanceof RequestMessage) {
				logMessage('Request:', content)
				switch request.method {
					case 'initialize':
						if (request.params instanceof InitializeParams)
							initialize(request.params as InitializeParams)
					case 'shutdown':
						return false
					case 'exit': {
						exitRequested = true
						return false
					}
				}
			} else if (request instanceof NotificationMessage) {
				logMessage('Notification:', content)
			}
			
			val context = new IServiceContext.Impl(request, session)
			response = serviceDispatcher.callService(context)
			
		} catch (InvalidRequestException e) {
			logException(e)
			response = respond(e.message, e.errorCode, e.requestId)
		} catch (Exception e) {
			logException(e)
			response = respond(e.message, ResponseError.INTERNAL_ERROR, null)
		}
		if (response !== null) {
			val responseText = jsonHandler.serialize(response)
			logMessage('Response:', responseText)
			val responseBytes = responseText.getBytes(charset)
			val header = CONTENT_LENGTH + ': ' + responseBytes.length + '\r\n\r\n'
			out.write(header.bytes)
			out.write(responseBytes)
		}
		return true
	}
	
	protected def ResponseMessage respond(String errorMessage, int errorCode, String requestId) {
		val response = new ResponseMessage
		response.jsonrpc = JSONRPC_VERSION
		if (requestId !== null)
			response.id = requestId
		response.error = new ResponseError => [
			message = errorMessage
			code = errorCode
		]
		return response
	}
	
	protected def initialize(InitializeParams params) {
		if (resourceBaseProvider !== null)
			resourceBaseProvider.resourceBase = params.rootPath
	}
	
	@Accessors
	static class ResourceBaseProvider implements IResourceBaseProvider {
	
		String resourceBase = ''
		
		override getFileURI(String resourceId) {
			if (resourceId.startsWith('file://'))
				URI.createURI(resourceId)
			else
				URI.createFileURI(resourceBase + File.separator + resourceId)
		}
		
	}
	
}