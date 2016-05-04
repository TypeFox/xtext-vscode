/*******************************************************************************
 * Copyright (c) 2016 TypeFox GmbH (http://www.typefox.io) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package io.typefox.xtext.vscode.statemachine;

import java.util.concurrent.ExecutorService;

import org.eclipse.xtext.ide.LexerIdeBindings;
import org.eclipse.xtext.ide.editor.contentassist.antlr.IContentAssistParser;
import org.eclipse.xtext.ide.editor.contentassist.antlr.internal.Lexer;
import org.eclipse.xtext.web.server.DefaultWebModule;
import org.xtext.example.statemachine.ide.contentassist.antlr.StatemachineParser;
import org.xtext.example.statemachine.ide.contentassist.antlr.internal.InternalStatemachineLexer;

import com.google.inject.Binder;
import com.google.inject.Provider;
import com.google.inject.name.Names;

/**
 * Manual modifications go to {@link StatemachineWebModule}.
 */
@SuppressWarnings("all")
public abstract class AbstractStatemachineWebModule extends DefaultWebModule {

	public AbstractStatemachineWebModule(Provider<ExecutorService> executorServiceProvider) {
		super(executorServiceProvider);
	}
	
	// contributed by org.eclipse.xtext.xtext.generator.web.WebIntegrationFragment
	public void configureContentAssistLexer(Binder binder) {
		binder.bind(Lexer.class).annotatedWith(Names.named(LexerIdeBindings.CONTENT_ASSIST)).to(InternalStatemachineLexer.class);
	}
	
	// contributed by org.eclipse.xtext.xtext.generator.web.WebIntegrationFragment
	public Class<? extends IContentAssistParser> bindIContentAssistParser() {
		return StatemachineParser.class;
	}
	
}
