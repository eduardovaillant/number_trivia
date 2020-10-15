import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/bloc/number_trivia_bloc.dart';
import 'package:number_trivia/injection_container.dart';
import '../widgets/widgets.dart';

class NumberTriviaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Number Trivia'),
      ),
      body: SingleChildScrollView(
        child: buildBody(context),
      ),
    );
  }
}

BlocProvider<NumberTriviaBloc> buildBody(BuildContext context) {
  return BlocProvider(
    create: (_) => sl<NumberTriviaBloc>(),
    child: Column(
      children: [
        SizedBox(height: 10),
        // Top Half
        BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
          builder: (context, state) {
            if (state is Empty) {
              return MessageDisplay(message: 'Start searching!');
            } else if (state is Loading) {
              return LoadingWidget();
            } else if (state is Loaded) {
              return TriviaDisplay(
                numberTrivia: state.trivia,
              );
            } else if (state is Error) {
              return MessageDisplay(
                message: state.message,
              );
            }
          },
        ),
        SizedBox(height: 20),
        // Botton half
        TriviaControls(),
      ],
    ),
  );
}

class TriviaControls extends StatefulWidget {
  const TriviaControls({
    Key key,
  }) : super(key: key);

  @override
  _TriviaControlsState createState() => _TriviaControlsState();
}

class _TriviaControlsState extends State<TriviaControls> {
  final controller = TextEditingController();
  String inputStr;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Input a number',
            ),
            onChanged: (value) {
              inputStr = value;
            },
            onSubmitted: (_) {
              dispatchConcrete();
            },
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: RaisedButton(
                  child: Text('Search'),
                  color: Theme.of(context).accentColor,
                  textTheme: ButtonTextTheme.primary,
                  onPressed: dispatchConcrete,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: RaisedButton(
                  child: Text('Get random trivia'),
                  onPressed: dispatchRandom,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void dispatchConcrete() {
    controller.clear();
    BlocProvider.of<NumberTriviaBloc>(context)
        .add(GetTriviaForConcreteNumber(inputStr));
    inputStr = '';
  }

  void dispatchRandom() {
    controller.clear();
    BlocProvider.of<NumberTriviaBloc>(context).add(GetTriviaForRandomNumber());
    inputStr = '';
  }
}
