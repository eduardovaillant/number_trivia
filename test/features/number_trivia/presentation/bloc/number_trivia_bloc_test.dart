import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia/core/util/input_converter.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/bloc/number_trivia_bloc.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

void main() {
  NumberTriviaBloc bloc;
  MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();

    bloc = NumberTriviaBloc(
      concrete: mockGetConcreteNumberTrivia,
      random: mockGetRandomNumberTrivia,
      inputConverter: mockInputConverter,
    );
  });

  test('initialState should be Empty', () {
    // assert
    expect(bloc.initialState, equals(Empty()));
  });

  group('GetTriviaForConcreteNumber', () {
    // The event takes in a String
    final tNumberString = '1';
    // This is the successful output of the InputConverter
    final tNumberParsed = int.parse(tNumberString);
    // NumberTrivia instance is need too, of course
    final tNumberTrivia = NumberTrivia(text: 'test trivia', number: 1);

    test(
        'should call the InputConverter to validate and convert the string to an unsigned integer',
        () async {
      // arrange
      when(mockInputConverter.stringToUnsignedInteger(any))
          .thenReturn(Right(tNumberParsed));
      // act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(mockInputConverter.stringToUnsignedInteger(any));
      // assert
      verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
    });

    test('should emit [Error] when the input is invalid', () async {
      // arrange
      when(mockInputConverter.stringToUnsignedInteger(any))
          .thenReturn(Left(InvalidInputFailure()));
      // assert later
      final expected = [
        // The initial state is always emitted first
        Empty(),
        Error(message: INVALID_INPUT_FAILURE_MESSAGE),
      ];
      expectLater(bloc, emitsInOrder(expected));
      // act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
    });
  });
}
