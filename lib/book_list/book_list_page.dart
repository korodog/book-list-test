import 'package:book_app/add_book/add_book_page.dart';
import 'package:book_app/domain/book.dart';
import 'package:book_app/edit_book/edit_book_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'book_list_model.dart';

class BookListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BookListModel>(
      create: (_) => BookListModel()..fetchBookList(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('本一覧'),
        ),
        body: Center(
          child: Consumer<BookListModel>(builder: (context, model, child) {
            final List<Book>? books = model.books;

            if (books == null) {
              return CircularProgressIndicator();
            }

            final List<Widget> widgets = books
                .map(
                    (book) => Slidable(
                      actionPane: SlidableDrawerActionPane(),
                      secondaryActions: <Widget>[
                        IconSlideAction(
                          caption: '編集',
                          color: Colors.black45,
                          icon: Icons.edit,
                          onTap: () async {
                            //  編集画面
                            final String? title = await Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) {
                                  // 表示する画面のWidget
                                  return EditBookPage(book);
                                },
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  // 遷移時のアニメーションを指定
                                  final Offset begin = Offset(1.0, 0.0);
                                  final Offset end = Offset.zero;
                                  final Tween<Offset> tween = Tween(begin: begin, end: end);
                                  final Animation<Offset> offsetAnimation = animation.drive(tween);
                                  return SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  );
                                },
                              ),
                            );
                            if (title != null) {
                              final snackBar = SnackBar(
                                backgroundColor: Colors.green,
                                content: Text('$titleを編集しました'),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            }
                            model.fetchBookList();
                          }
                        ),
                        IconSlideAction(
                          caption: '削除',
                          color: Colors.red,
                          icon: Icons.delete,
                          onTap: () async {
                            await showConfirmDialog(context, book, model);
                          },
                        ),
                      ],
                      child: ListTile(
                        leading: book.imgURL != null
                          ? Image.network(book.imgURL!)
                          : null,
                        title: Text(book.title),
                        subtitle: Text(book.author),
                      ),
                    ),
            ).toList();
            return ListView(
              children: widgets,
            );
          })
        ),
        floatingActionButton: Consumer<BookListModel>(builder: (context, model, child) {
            return FloatingActionButton(
              onPressed: () async {
                final bool? added = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddBookPage(),
                    fullscreenDialog: true,
                  ),
                );
                if (added != null && added) {
                  final snackBar = SnackBar(
                    backgroundColor: Colors.green,
                    content: Text('本を追加しました'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
                model.fetchBookList();
              },
              tooltip: 'Increment',
              child: Icon(Icons.add),
            );
          }
        ),
      ),
    );
  }
}

Future showConfirmDialog(
    BuildContext context,
    Book book,
    BookListModel model,
    ) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return AlertDialog(
        title: Text('削除の確認'),
        content: Text("『${book.title}』を削除しますか？"),
        actions: [
          TextButton(
            child: Text("はい"),
            onPressed: () async {
              await model.deleteBook(book);
              Navigator.pop(context);

              final snackBar = SnackBar(
                backgroundColor: Colors.red,
                content: Text('${book.title}を削除しました。'),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
              model.fetchBookList();
            },
          ),
          TextButton(
            child: Text("いいえ"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    },
  );
}