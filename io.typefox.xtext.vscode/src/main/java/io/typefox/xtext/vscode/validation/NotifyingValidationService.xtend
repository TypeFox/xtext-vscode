/*******************************************************************************
 * Copyright (c) 2016 TypeFox GmbH (http://www.typefox.io) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package io.typefox.xtext.vscode.validation

import com.google.inject.Inject
import io.typefox.lsapi.DiagnosticSeverity
import io.typefox.lsapi.impl.DiagnosticImpl
import io.typefox.xtext.vscode.DocumentPositionHelper
import io.typefox.xtext.vscode.XtextWebLanguageServer
import org.eclipse.xtext.util.CancelIndicator
import org.eclipse.xtext.web.server.model.IXtextWebDocument
import org.eclipse.xtext.web.server.validation.ValidationService

class NotifyingValidationService extends ValidationService {
	
	@Inject XtextWebLanguageServer server
	@Inject extension DocumentPositionHelper
	
	override compute(IXtextWebDocument document, CancelIndicator cancelIndicator) {
		val result = super.compute(document, cancelIndicator)
		val diagList = result.issues.map[ issue |
			new DiagnosticImpl => [
				source = 'Xtext'
				range = getRange(document, issue.offset, issue.length)
				severity = switch issue.severity {
					case 'error': DiagnosticSeverity.Error
					case 'warning': DiagnosticSeverity.Warning
					case 'info': DiagnosticSeverity.Information
					default: DiagnosticSeverity.Hint
				}
				message = issue.description
			]
		]
		server.publishDiagnostics(document.resourceId, diagList)
		return result
	}
	
}