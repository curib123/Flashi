import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:elegant_notification/resources/stacked_options.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_create_set_button_position.dart';
import 'package:flashlearn/presentation/widget/reusable_widgets/reusable_theme_setting_position.dart';
import 'package:flashlearn/provider/notes_provider.dart';
import 'package:flashlearn/util/helpers/snackbar/reusable_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';

class CreateNoteScreen extends StatelessWidget {
  final bool isCreate;
  final bool isRead;
  final String title;
  final DateTime date;

  const CreateNoteScreen({
    Key? key,
    required this.isCreate,
    required this.title,
    required this.isRead, required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final noteProvider = Provider.of<NotesProvider>(context);
    final size = MediaQuery.of(context).size;



    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(colorScheme, context,title),
      body: Stack(
        children: [
          _buildBody(size,noteProvider),
          _buildTitleInputField(noteProvider),
         !isRead ? ReusableCreateSetButtonPosition(
           icon: Icons.add_rounded,
            colorScheme: colorScheme,
            name: isCreate ?  'Save' : 'Save Changes',
            onTap: () => {
              if(noteProvider.titleController.text.isNotEmpty){
                _onSaveTap(context, noteProvider)
              }else{
           ElegantNotification.info(
           width: 300,
           notificationMargin: 0,
           stackedOptions: StackedOptions(
             type: StackedType.same,
             key: '',
           ),
           position: Alignment.topCenter,
           animation: AnimationType.fromTop,
           title: Text('ALERT'),
           description: Text('REQUIRED TITLE'),
           onDismiss: () {},
         ).show(context),
              }
            },
          ): const Text(''),
          ReusableThemeSettingPosition(colorScheme: colorScheme),
        ],
      ),
    );
  }

  AppBar _buildAppBar(ColorScheme colorScheme, BuildContext context,String title) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.onPrimary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: !isRead ? Text(
        isCreate ? "Create Note" : "Edit Note",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: colorScheme.onPrimary,
        ),
      ) : Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text('View Note', style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: colorScheme.onPrimary,
        ),),
        SizedBox(width: 10),
        IconButton(
          icon: Icon(Icons.edit, color: colorScheme.onPrimary),
          onPressed: () => {

            Navigator.pop(context),
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => CreateNoteScreen(
                isCreate: false,
                title: title,
                isRead: false,
                date: date,
              ),
            )),


        },
        ),],
      ),
      backgroundColor: colorScheme.primary,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
    );
  }

  Widget _buildBody(Size size, NotesProvider noteProvider) {
    String formattedDate = DateFormat('MMM dd, yyyy - hh:mm a').format(date);
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 10),
      children: [
        SizedBox(height: 80),
        Text('Content ',style: TextStyle(color: Colors.grey),),
        _buildContentInputField(size,noteProvider),
        Center(child: Text(formattedDate))
      ],
    );
  }

  Widget _buildTitleInputField(NotesProvider noteProvider) {
    return  Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 20,vertical: 15),
          child: TextField(
            readOnly: isRead,
            controller: noteProvider.titleController,
            decoration: InputDecoration(
              hintText: 'Title Here',
              border: InputBorder.none,
            ),
            style: TextStyle(fontSize: 18),
          ),

    );
  }

  Widget _buildContentInputField(Size size, NotesProvider noteProvider) {
    return Container(
      width: size.width,
      child: TextField(
        readOnly: isRead,
        controller: noteProvider.contentController,
        maxLines: 21,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          hintText: 'Type your content here...',
          border: InputBorder.none,
        ),
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  void _onSaveTap(BuildContext context, NotesProvider noteProvider) {
    if (isCreate ) {
      noteProvider.addNote({
        'title': noteProvider.titleController.text,
        'content': noteProvider.contentController.text,
        'created_at': DateTime.now(),
        'favorite': false,
      });
      Appodeal.show(AppodealAdType.Interstitial);
      showCustomSnackbar(context: context, message: 'Note created successfully!');
      noteProvider.titleController.clear();
      noteProvider.contentController.clear();
      Navigator.pop(context);
    } else {
      noteProvider.editNoteByTitle(
          title,
          {
            'title': noteProvider.titleController.text,
            'content': noteProvider.contentController.text,
            'created_at': DateTime.now(),
            'favorite': false,
          });
      Navigator.pop(context);
      showCustomSnackbar(context: context, message: 'Note updated successfully!');
    }
  }
}
