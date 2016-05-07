/*******************************************************************************
 * Copyright (c) 2016 TypeFox GmbH (http://www.typefox.io) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package io.typefox.xtext.vscode.validation

import com.google.inject.Inject
import io.typefox.xtext.vscode.DocumentPositionHelper
import io.typefox.xtext.vscode.INotificationAcceptor
import io.typefox.xtext.vscode.protocol.Diagnostic
import io.typefox.xtext.vscode.protocol.NotificationMessage
import io.typefox.xtext.vscode.protocol.params.PublishDiagnosticsParams
import org.eclipse.xtext.util.CancelIndicator
import org.eclipse.xtext.web.server.model.IXtextWebDocument
import org.eclipse.xtext.web.server.validation.ValidationService

class NotifyingValidationService extends ValidationService {
	
	@Inject INotificationAcceptor notificationAcceptor
	@Inject extension DocumentPositionHelper
	
	override compute(IXtextWebDocument document, CancelIndicator cancelIndicator) {
		val result = super.compute(document, cancelIndicator)
		val diagList = result.issues.map[ issue |
			new Diagnostic => [
				source = 'Xtext'
				range = getRange(document, issue.offset, issue.length)
				severity = switch issue.severity {
					case 'error': Diagnostic.SEVERITY_ERROR
					case 'warning': Diagnostic.SEVERITY_WARNING
					case 'info': Diagnostic.SEVERITY_INFO
					default: Diagnostic.SEVERITY_HINT
				}
				message = issue.description
			]
		]
		notificationAcceptor.accept(new NotificationMessage => [
			method = 'textDocument/publishDiagnostics'
			params = new PublishDiagnosticsParams => [
				uri = document.resourceId
				diagnostics = diagList
			]
		])
		return result
	}
	
}