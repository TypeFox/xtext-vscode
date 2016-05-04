/*******************************************************************************
 * Copyright (c) 2016 TypeFox GmbH (http://www.typefox.io) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.xtext.example.statemachine.ide.contentassist

import org.eclipse.xtend2.lib.StringConcatenationClient
import org.eclipse.xtext.ide.editor.contentassist.AbstractIdeTemplateProposalProvider
import org.eclipse.xtext.ide.editor.contentassist.ContentAssistContext
import org.eclipse.xtext.ide.editor.contentassist.IIdeContentProposalAcceptor

class StatemachineTemplateProposalProvider extends AbstractIdeTemplateProposalProvider {
	
	def void createStateProposal(ContentAssistContext context, IIdeContentProposalAcceptor acceptor) {
		val StringConcatenationClient template = '''
			state «variable('name')»
				«cursor»
			end
		'''
		acceptProposal('state', 'Create a new state', template, context, acceptor)
	}
	
}
