/*
 * Copyright (c) 2022, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
@IsTest
global class Assertions {
  global interface MethodSpyAssertions {
    /**
     * Assert that a method spy has never been called
     */
    void hasNotBeenCalled();

    /**
     * Assert that a method spy has been called at least one time with any parameters
     */
    void hasBeenCalled();

    /**
     * Assert that a method spy has been called exactly N times with any parameters
     *
     * @param count number of times the method spy should have been called
     */
    void hasBeenCalledTimes(final Integer count);

    /**
     * Assert that a method spy has been called at least one time with matching parameters
     *
     * @param param1 params that should match one call parameters
     * @see          Params
     */
    void hasBeenCalledWith();
    void hasBeenCalledWith(final Object param1);
    void hasBeenCalledWith(final Object param1, final Object param2);
    void hasBeenCalledWith(final Object param1, final Object param2, final Object param3);
    void hasBeenCalledWith(final Object param1, final Object param2, final Object param3, final Object param4);
    void hasBeenCalledWith(final Object param1, final Object param2, final Object param3, final Object param4, final Object param5);

    /**
     * Assert that a method spy has been lastly called with matching parameters
     *
     * @param params params that should match last call parameters
     * @see          Params
     */
    void hasBeenLastCalledWith();
    void hasBeenLastCalledWith(final Object param1);
    void hasBeenLastCalledWith(final Object param1, final Object param2);
    void hasBeenLastCalledWith(final Object param1, final Object param2, final Object param3);
    void hasBeenLastCalledWith(final Object param1, final Object param2, final Object param3, final Object param4);
    void hasBeenLastCalledWith(final Object param1, final Object param2, final Object param3, final Object param4, final Object param5);
  }

  global interface ErrorMessage {
    String toString();
  }

  global interface Asserter {
    void isTrue(Boolean value, ErrorMessage message);
    void isFalse(Boolean value, ErrorMessage message);
  }

  /**
   * Starts to build assertions on a method spy
   *
   * @param spy the MethodSpy to assert
   * @see       MethodSpy
   */
  global static MethodSpyAssertions assertThat(MethodSpy spy) {
    return assertThat(spy, METHOD_SPY_ASSERTER);
  }

  /**
   * Starts to build assertions on a method spy using a custom asserter
   *
   * @param spy      the MethodSpy to assert
   * @param asserter the Assert to use during assertions
   */
  @TestVisible
  private static MethodSpyAssertions assertThat(MethodSpy spy, Asserter asserter) {
    return new DefaultMethodSpyAssertions(spy, asserter);
  }

  @TestVisible
  private class MethodSpyAsserter implements Asserter {
    public void isTrue(Boolean value, ErrorMessage message) {
      // Do not use Assert.isTrue to check value
      // Because we want to compute ErrorMessage to string()
      // only when the Boolean is false
      if (!value) {
        Assert.fail(message.toString());
      }
    }
    public void isFalse(Boolean value, ErrorMessage message) {
      // Do not use Assert.isFalse to check value
      // Because we want to compute ErrorMessage to string()
      // only when the Boolean is true
      if (value) {
        Assert.fail(message.toString());
      }
    }
  }

  private static final Asserter METHOD_SPY_ASSERTER = new MethodSpyAsserter();

  private class DefaultMethodSpyAssertions implements MethodSpyAssertions {
    private MethodSpy spy;
    private Asserter asserter;

    private DefaultMethodSpyAssertions(MethodSpy spy) {
      this.spy = spy;
      this.asserter = METHOD_SPY_ASSERTER;
    }

    private DefaultMethodSpyAssertions(MethodSpy spy, Asserter asserter) {
      this(spy);
      this.asserter = asserter;
    }

    public void hasNotBeenCalled() {
      this.asserter.isTrue(this.spy.callLog.isEmpty(), buildErrorMessage(this.spy, ErrorMessageType.CALLED));
    }

    public void hasBeenCalled() {
      this.asserter.isFalse(this.spy.callLog.isEmpty(), buildErrorMessage(this.spy, ErrorMessageType.NEVER_CALLED));
    }

    public void hasBeenCalledTimes(final Integer count) {
      this.asserter.isTrue(this.spy.callLog.size() == count, buildErrorMessage(this.spy, ErrorMessageType.NOT_CALLED_TIMES, count));
    }

    public void hasBeenCalledWith() {
      this.hasBeenCalledWithParams(Params.empty());
    }

    public void hasBeenCalledWith(final Object arg) {
      this.hasBeenCalledWithParams((arg instanceof Params) ? (Params) arg : Params.of(arg));
    }

    public void hasBeenCalledWith(final Object arg1, final Object arg2) {
      this.hasBeenCalledWithParams(Params.of(arg1, arg2));
    }

    public void hasBeenCalledWith(final Object arg1, final Object arg2, final Object arg3) {
      this.hasBeenCalledWithParams(Params.of(arg1, arg2, arg3));
    }

    public void hasBeenCalledWith(final Object arg1, final Object arg2, final Object arg3, final Object arg4) {
      this.hasBeenCalledWithParams(Params.of(arg1, arg2, arg3, arg4));
    }

    public void hasBeenCalledWith(final Object arg1, final Object arg2, final Object arg3, final Object arg4, final Object arg5) {
      this.hasBeenCalledWithParams(Params.of(arg1, arg2, arg3, arg4, arg5));
    }

    private void hasBeenCalledWithParams(final Params params) {
      Boolean hasBeenCalledWithParams = false;
      for (Integer i = 0; i < this.spy.callLog.size(); ++i) {
        if (params?.matches(this.spy.callLog.get(i))) {
          hasBeenCalledWithParams = true;
          break;
        }
      }
      this.asserter.isFalse(this.spy.callLog.isEmpty(), buildErrorMessage(this.spy, ErrorMessageType.NEVER_CALLED));
      this.asserter.isTrue(hasBeenCalledWithParams, buildErrorMessage(this.spy, ErrorMessageType.NOT_CALLED_WITH, params));
    }

    public void hasBeenLastCalledWith() {
      this.hasBeenLastCalledWithParams(Params.empty());
    }

    public void hasBeenLastCalledWith(final Object arg) {
      this.hasBeenLastCalledWithParams((arg instanceof Params) ? (Params) arg : Params.of(arg));
    }

    public void hasBeenLastCalledWith(final Object arg1, final Object arg2) {
      this.hasBeenLastCalledWithParams(Params.of(arg1, arg2));
    }

    public void hasBeenLastCalledWith(final Object arg1, final Object arg2, final Object arg3) {
      this.hasBeenLastCalledWithParams(Params.of(arg1, arg2, arg3));
    }

    public void hasBeenLastCalledWith(final Object arg1, final Object arg2, final Object arg3, final Object arg4) {
      this.hasBeenLastCalledWithParams(Params.of(arg1, arg2, arg3, arg4));
    }

    public void hasBeenLastCalledWith(final Object arg1, final Object arg2, final Object arg3, final Object arg4, final Object arg5) {
      this.hasBeenLastCalledWithParams(Params.of(arg1, arg2, arg3, arg4, arg5));
    }

    private void hasBeenLastCalledWithParams(final Params params) {
      this.asserter.isFalse(this.spy.callLog.isEmpty(), buildErrorMessage(this.spy, ErrorMessageType.NEVER_CALLED));
      this.asserter.isTrue(params?.matches(this.spy.callLog.getLast()), buildErrorMessage(this.spy, ErrorMessageType.NOT_LAST_CALLED_WITH, params));
    }
  }

  private enum ErrorMessageType {
    CALLED,
    NEVER_CALLED,
    NOT_CALLED_WITH,
    NOT_LAST_CALLED_WITH,
    NOT_CALLED_TIMES
  }

  private class ErrorMessageRow {
    protected String message;
    protected Boolean tabbed;

    ErrorMessageRow(String message) {
      this(message, false);
    }
    ErrorMessageRow(String message, Boolean tabbed) {
      this.message = message;
      this.tabbed = tabbed;
    }
  }

  private class ErrorMessageImpl implements ErrorMessage {
    private MethodSpy spy;
    private ErrorMessageType error;
    private Object argument;

    ErrorMessageImpl(MethodSpy spy, ErrorMessageType error) {
      this(spy, error, null);
    }
    ErrorMessageImpl(MethodSpy spy, ErrorMessageType error, Object argument) {
      this.spy = spy;
      this.error = error;
      this.argument = argument;
    }

    private String buildHeadline(MethodSpy spy, ErrorMessageType error, Object argument) {
      final Map<ErrorMessageType, String> messages = new Map<ErrorMessageType, String>{
        ErrorMessageType.CALLED => 'Method {0} was called',
        ErrorMessageType.NEVER_CALLED => 'Method {0} was not called',
        ErrorMessageType.NOT_CALLED_WITH => 'Method {0} was not called with {1}',
        ErrorMessageType.NOT_LAST_CALLED_WITH => 'Method {0} was not last called with {1}',
        ErrorMessageType.NOT_CALLED_TIMES => 'Method {0} was not called {1} times'
      };
      return String.format(messages.get(error), new List<String>{ spy.methodName, argument + '' });
    }

    private List<ErrorMessageRow> buildCallTraces(MethodSpy spy) {
      final List<Params> reversedCallLogParams = new List<Params>();
      for (Integer i = this.spy.callLog.size() - 1; i >= 0; i--) {
        reversedCallLogParams.add(Params.ofList(this.spy.callLog.get(i)));
      }

      if (reversedCallLogParams.isEmpty()) {
        return new List<ErrorMessageRow>();
      }

      final List<ErrorMessageRow> rows = new List<ErrorMessageRow>();
      rows.add(new ErrorMessageRow('method call history:'));
      final String template = '#{0} {1}({2})';
      for (Integer i = 0; i < reversedCallLogParams.size(); i++) {
        final Params params = reversedCallLogParams[i];
        final Integer count = reversedCallLogParams.size() - i;
        rows.add(new ErrorMessageRow(String.format(template, new List<Object>{ count, spy.methodName, params }), true));
      }
      return rows;
    }

    override public String toString() {
      final String headline = this.buildHeadline(spy, error, argument);
      final List<ErrorMessageRow> callTraces = this.buildCallTraces(spy);

      final List<String> lines = new List<String>();
      lines.add(headline);
      if (!callTraces.isEmpty()) {
        for (ErrorMessageRow row : callTraces) {
          final String prefix = row.tabbed ? '\t' : '';
          final String line = prefix + row.message;
          lines.add(line);
        }
        lines.add('');
      }
      return String.join(lines, '\n');
    }
  }

  private static ErrorMessage buildErrorMessage(MethodSpy spy, ErrorMessageType error) {
    return new ErrorMessageImpl(spy, error);
  }

  private static ErrorMessage buildErrorMessage(MethodSpy spy, ErrorMessageType error, Object argument) {
    return new ErrorMessageImpl(spy, error, argument);
  }
}
