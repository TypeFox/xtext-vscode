/*******************************************************************************
 * Copyright (c) 2016 TypeFox GmbH (http://www.typefox.io) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package io.typefox.xtext.vscode.statemachine

import com.google.inject.Binder
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.eclipse.xtext.ide.editor.contentassist.IdeContentProposalProvider
import org.eclipse.xtext.web.server.persistence.FileResourceHandler
import org.eclipse.xtext.web.server.persistence.IResourceBaseProvider
import org.eclipse.xtext.web.server.persistence.IServerResourceHandler
import org.xtext.example.statemachine.ide.contentassist.StatemachineWebContentProposalProvider

/** 
 * Use this class to register components to be used within the web application.
 */
@FinalFieldsConstructor
class StatemachineWebModule extends AbstractStatemachineWebModule {

	val IResourceBaseProvider resourceBaseProvider

	def void configureResourceBaseProvider(Binder binder) {
		if (resourceBaseProvider !== null) binder.bind(IResourceBaseProvider).toInstance(resourceBaseProvider)
	}

	def Class<? extends IServerResourceHandler> bindIServerResourceHandler() {
		return FileResourceHandler
	}
	
	def Class<? extends IdeContentProposalProvider> bindIdeContentProposalProvider() {
		return StatemachineWebContentProposalProvider
	}

}
