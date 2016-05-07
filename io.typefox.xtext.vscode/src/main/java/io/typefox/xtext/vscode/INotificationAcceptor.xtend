/*******************************************************************************
 * Copyright (c) 2016 TypeFox GmbH (http://www.typefox.io) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package io.typefox.xtext.vscode

import com.google.inject.ImplementedBy
import io.typefox.xtext.vscode.protocol.NotificationMessage

@ImplementedBy(LanguageServer)
interface INotificationAcceptor {
	
	def void accept(NotificationMessage message)
	
}