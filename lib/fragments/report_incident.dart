import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';

class ReportIncident extends StatefulWidget {
  @override
  _ReportIncidentState createState() => _ReportIncidentState();
}

class _ReportIncidentState extends State<ReportIncident> {

  File _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera,imageQuality: 50);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }


  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
      child: ListView(
        children: [Column(
          children: <Widget>[
            Text("Report an Incident", style: TextStyle(fontSize: 20, decoration: TextDecoration.underline),),
            FormBuilder(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  FormBuilderTextField(
                    attribute: 'code',
                    decoration: InputDecoration(
                      labelText:
                      'Incident Number/CRQ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  FormBuilderChoiceChip(
                    attribute: 'choice_chip',
                    decoration: InputDecoration(
                      labelText: 'Select type of incident',
                    ),
                    options: [
                      FormBuilderFieldOption(
                          value: 'Test', child: Text('Severe')),
                      FormBuilderFieldOption(
                          value: 'Test 1', child: Text('Blah blah blah')),
                      FormBuilderFieldOption(
                          value: 'Test 2', child: Text('Type 3')),
                      FormBuilderFieldOption(
                          value: 'Test 3', child: Text('Another type')),
                      FormBuilderFieldOption(
                          value: 'Test 4', child: Text('Another type')),
                    ],
                  ),
                  FormBuilderChoiceChip(
                    attribute: 'choice_chip',
                    decoration: InputDecoration(
                      labelText: 'Select Region',
                    ),
                    options: [
                      FormBuilderFieldOption(
                          value: 'Test', child: Text('Mt Kenya')),
                      FormBuilderFieldOption(
                          value: 'Test 1', child: Text('Nairobi')),
                      FormBuilderFieldOption(
                          value: 'Test 2', child: Text('Western')),
                      FormBuilderFieldOption(
                          value: 'Test 3', child: Text('Coastal regions')),
                      FormBuilderFieldOption(
                          value: 'Test 4', child: Text('RiftValley')),
                    ],
                  ),
                  _image == null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RaisedButton(
                        color: Colors.redAccent,
                        textColor: Colors.white,
                        onPressed: getImage,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo),
                            SizedBox(width: 10,),
                            Text('Attach Image')
                          ],
                        ),),
                    ),
                  )
                      : Image.file(_image),
                ],
              ),
            ),
            Row(
              children: <Widget>[

                SizedBox(width: 20),
                Expanded(
                  child: MaterialButton(
                    color: Theme.of(context).accentColor,
                    child: Text(
                      "Submit",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      _formKey.currentState.save();
                      if (_formKey.currentState.validate()) {
                        print(_formKey.currentState.value);
                      } else {
                        print("validation failed");
                      }
                    },
                  ),
                ),
                SizedBox(width: 20),
              ],
            ),
          ],
        )],
      ),
    );
  }
}
