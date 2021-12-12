import 'package:exerlog/Bloc/exercise_bloc.dart';
import 'package:exerlog/Bloc/user_bloc.dart';
import 'package:exerlog/Bloc/workout_bloc.dart';
import 'package:exerlog/Models/exercise.dart';
import 'package:exerlog/Models/sets.dart';
import 'package:exerlog/Models/workout.dart';
import 'package:exerlog/Models/workout_data.dart';
import 'package:exerlog/UI/exercise/add_exercise_widget.dart';
import 'package:exerlog/UI/exercise/add_new_exercise_alert.dart';
import 'package:exerlog/UI/exercise/exercise_card.dart';
import 'package:exerlog/UI/exercise/totals_widget.dart';
import 'package:exerlog/UI/gradient_border_button.dart';
import 'package:exerlog/UI/workout/add_new_workout_alert.dart';
import 'package:exerlog/UI/workout/save_workout_dialog.dart';
import 'package:exerlog/UI/workout/workout_name_selection_widget.dart';
import 'package:exerlog/UI/workout/workout_toatals_widget.dart';
import 'package:flutter/material.dart';
import '../gradient_button.dart';
import '../global.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage();

  @override
  _WorkoutPageState createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  late WorkoutTotalsWidget workoutTotalsWidget;
  late WorkoutData workoutData;
  String exerciseName = '';
  late bool firstLoad;

  @override
  void initState() {
    firstLoad = true;
    // TODO: implement initState
    workoutData = new WorkoutData(new Workout([], '', '', 0, '', '', false),
        new WorkoutTotals(0, 0, 0, 0, 0), updateTotals);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (firstLoad) {
      Future.delayed(Duration.zero, () => showAlertDialogWorkout(context));
    }
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    workoutData =
        new WorkoutData(workoutData.workout, workoutData.totals, updateTotals);
    workoutTotalsWidget = new WorkoutTotalsWidget(totals: workoutData.totals);
    return Material(
      child: firstLoad
          ? Container(
              color: backgroundColor,
            )
          : GestureDetector(
              child: Container(
                color: backgroundColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(),
                    WorkoutTotalsWidget(
                      totals: workoutData.totals,
                    ),
                    Container(
                      height: screenHeight * 0.5,
                      child: ListView(
                        addAutomaticKeepAlives: true,
                        children: workoutData.exerciseWidgets,
                      ),
                    ),
                    Container(
                      height: screenHeight * 0.065,
                      width: screenWidth * 0.9,
                      child: GradientBorderButton(
                        gradient: LinearGradient(
                          colors: <Color>[Color(0xFF34D1C2), Color(0xFF31A6DC)],
                        ),
                        radius: 30,
                        borderSize: 3,
                        onPressed: () {
                          // create new exercise
                          showAlertDialogExercise(context);
                        },
                        child: Container(
                          width: screenWidth * 0.6,
                          child: Center(
                              child: Text(
                            "Add New Exercise",
                            style: greenButtonTextThin,
                          )),
                        ),
                      ),
                    ),
                    Container(
                      height: screenHeight * 0.065,
                      width: screenWidth * 0.9,
                      margin: EdgeInsets.only(bottom: 30),
                      child: RaisedGradientButton(
                        gradient: LinearGradient(
                          colors: <Color>[Color(0xFF34D1C2), Color(0xFF31A6DC)],
                        ),
                        radius: 30,
                        borderSize: 0,
                        onPressed: () {
                          for (Exercise exercise
                              in workoutData.workout.exercises) {
                            for (Sets sets in exercise.sets) {
                              if (sets.reps == 0) {
                                exercise.sets.remove(sets);
                              }
                            }
                            if (exercise.sets.length == 0) {
                              workoutData.workout.exercises.remove(exercise);
                            }
                          }
                          if (workoutData.workout.exercises.length > 0) {
                            showSaveWorkoutAlertDialog(context);
                          }
                        },
                        child: Container(
                          child: Center(
                              child: Text(
                            "Save",
                            style: buttonText,
                          )),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  setExercisename(name) {
    exerciseName = name;
  }

  setWorkout(name, template) {
    workoutData.workout.name = name;
    workoutData.workout.template = template;
  }

  updateTotals(workout) {
    setState(() {
      firstLoad = false;
      print(workoutData.workout.exercises[0].toJson());
      workoutData.workout = workout;
    });
  }

  showAlertDialogExercise(BuildContext context) {
    ExerciseNameSelectionWidget exerciseNameSelectionWidget =
        new ExerciseNameSelectionWidget(
      setExercisename: setExercisename,
    );
    // set up the button
    RaisedGradientButton okButton = RaisedGradientButton(
      gradient: LinearGradient(
        colors: <Color>[Color(0xFF34D1C2), Color(0xFF31A6DC)],
      ),
      radius: 30,
      borderSize: 0,
      child: Text(
        "ADD",
        style: buttonTextSmall,
      ),
      onPressed: () {
        if (exerciseName != '') {
          setState(() {
            workoutData.addExercise(new Exercise(exerciseName, [], []));
            workoutData.setExerciseWidgets();
          });
          Navigator.pop(context);
        }
      },
    );

    // set up the AlertDialog
    AddExerciseAlert alert =
        AddExerciseAlert(okButton, exerciseNameSelectionWidget);

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showSaveWorkoutAlertDialog(BuildContext context) {
    RaisedGradientButton okButton = RaisedGradientButton(
      gradient: LinearGradient(
        colors: <Color>[Color(0xFF34D1C2), Color(0xFF31A6DC)],
      ),
      radius: 30,
      borderSize: 0,
      child: Text(
        "SAVE",
        style: buttonTextSmall,
      ),
      onPressed: () {
        saveWorkout(workoutData.workout);
        setState(() {
          firstLoad = true;
          workoutData = new WorkoutData(
              new Workout([], '', '', 0, '', '', false),
              new WorkoutTotals(0, 0, 0, 0, 0),
              updateTotals);
        });
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    SaveWorkoutAlert alert = SaveWorkoutAlert(okButton, setWorkout);

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  setWorkoutName(name) {
    workoutData.workout.name = name;
  }

  addExercises(workout) async {
    List<Sets> setList = [];
    workoutData.workout = workout;
    int i = 0;
    for (String exercise_id in workout.exercises) {
      await getSpecificExercise(exercise_id).then((value) async => {
            await getExerciseByName(value.name).then((exercise) => {
                  setList = [],
                  for (var sets in exercise.sets)
                    {
                      setList.add(new Sets(sets['reps'], sets['rest'],
                          sets['weight'], sets['sets']))
                    },
                  workoutData.workout.exercises[i] =
                      new Exercise(exercise.name, setList, exercise.bodyParts),
                  workoutData.workout.template = true,
                }),
            i++
          });
    }
    updateTotals(workoutData.workout);
  }

  showAlertDialogWorkout(BuildContext context) {
    WorkoutTemplateSelectionWidget workoutTemplateSelectionWidget =
        new WorkoutTemplateSelectionWidget(
      setWorkout: addExercises,
    );
    RaisedGradientButton okButton = RaisedGradientButton(
      gradient: LinearGradient(
        colors: <Color>[Color(0xFF34D1C2), Color(0xFF31A6DC)],
      ),
      radius: 30,
      borderSize: 0,
      child: Text(
        "START",
        style: buttonTextSmall,
      ),
      onPressed: () {
        setState(() {
          firstLoad = false;
        });
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AddWorkoutAlert alert =
        AddWorkoutAlert(okButton, workoutTemplateSelectionWidget);

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
