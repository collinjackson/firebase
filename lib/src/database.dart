library firebase.database;

import 'dart:async';

import 'app.dart';
import 'event.dart';
import 'data_snapshot.dart';
import 'flutter/database.dart';

abstract class FirebaseDatabase {
  /// Firebase app instance that corresponds to this database
  FirebaseApp get app;

  /// Firebase database associated with the default app 
  static FirebaseDatabase get instance => FirebaseDatabaseImpl.instance;

  /// Returns a database reference pointing to the root of the database.
  DatabaseReference reference([ String path ]);
}

abstract class DatabaseReference extends Query {
  /**
   * Get a Firebase reference for a location at the specified relative path.
   *
   * The relative path can either be a simple child name, (e.g. 'fred') or a
   * deeper slash separated path (e.g. 'fred/name/first').
   */
  DatabaseReference child(String path);

  /**
   * Get a Firebase reference for the parent location. If this instance refers
   * to the root of your Firebase, it has no parent, and therefore parent()
   * will return null.
   */
  DatabaseReference parent();

  /**
   * Get a Firebase reference for the root of the Firebase.
   */
  DatabaseReference root();

  /**
   * Write data to this Firebase location. This will overwrite any data at
   * this location and all child locations.
   *
   * The effect of the write will be visible immediately and the corresponding
   * events ('onValue', 'onChildAdded', etc.) will be triggered.
   * Synchronization of the data to the Firebase servers will also be started,
   * and the Future returned by this method will complete after synchronization
   * has finished.
   *
   * Passing null for the new value is equivalent to calling remove().
   *
   * A single set() will generate a single onValue event at the location where
   * the set() was performed.
   */
  Future set(value);

  // /**
  //  * Write the enumerated children to this Firebase location. This will only
  //  * overwrite the children enumerated in the 'value' parameter and will leave
  //  * others untouched.
  //  *
  //  * The returned Future will be complete when the synchronization has
  //  * completed with the Firebase servers.
  //  */
  // Future update(Map<String, dynamic> value);

  /**
   * Remove the data at this Firebase location. Any data at child locations
   * will also be deleted.
   *
   * The effect of this delete will be visible immediately and the
   * corresponding events (onValue, onChildAdded, etc.) will be triggered.
   * Synchronization of the delete to the Firebase servers will also be
   * started, and the Future returned by this method will complete after the
   * synchronization has finished.
   */
  Future remove();

  /**
   * Push generates a new child location using a unique name and returns a
   * Firebase reference to it. This is useful when the children of a Firebase
   * location represent a list of items.
   *
   * The unique name generated by push() is prefixed with a client-generated
   * timestamp so that the resulting list will be chronologically sorted.
   */
  DatabaseReference push();

  /**
   * Write data to a Firebase location, like set(), but also specify the
   * priority for that data. Identical to doing a set() followed by a
   * setPriority(), except it is combined into a single atomic operation to
   * ensure the data is ordered correctly from the start.
   *
   * Returns a Future which will complete when the data has been synchronized
   * with Firebase.
   */
  Future setWithPriority(value, int priority);

  /**
   * Set a priority for the data at this Firebase location. A priority can
   * be either a number or a string and is used to provide a custom ordering
   * for the children at a location. If no priorities are specified, the
   * children are ordered by name. This ordering affects the enumeration
   * order of DataSnapshot.forEach(), as well as the prevChildName parameter
   * passed to the onChildAdded and onChildMoved event handlers.
   *
   * You cannot set a priority on an empty location. For this reason,
   * setWithPriority() should be used when setting initial data with a
   * specific priority, and this function should be used when updating the
   * priority of existing data.
   */
  Future setPriority(int priority);
}

abstract class Query {
  /**
   * Streams for various data events.
   */
  Stream<Event> get onValue;

  Stream<Event> get onChildAdded;

  Stream<Event> get onChildMoved;

  Stream<Event> get onChildChanged;

  Stream<Event> get onChildRemoved;

  /**
   * Listens for exactly one event of the specified event type, and then stops
   * listening.
   */
  Future<DataSnapshot> once(String eventType);

  /**
   * Generates a new Query object ordered by the specified child key.
   */
  Query orderByChild(String key);

  /**
   * Generates a new Query object ordered by key.
   */
  Query orderByKey();

  /**
   * Generates a new Query object ordered by child values.
   */
  Query orderByValue();

  /**
   * Generates a new Query object ordered by priority.
   */
  Query orderByPriority();

  /**
   * Creates a Query with the specified starting point. The generated Query
   * includes children which match the specified starting point. If no arguments
   * are provided, the starting point will be the beginning of the data.
   *
   * The starting point is inclusive, so children with exactly the specified
   * priority will be included. Though if the optional name is specified, then
   * the children that have exactly the specified priority must also have a
   * name greater than or equal to the specified name.
   *
   * startAt() can be combined with endAt() or limitToFirst() or limitToLast()
   * to create further restrictive queries.
   */
  Query startAt({dynamic value, String key});

  /**
   * Creates a Query with the specified ending point. The generated Query
   * includes children which match the specified ending point. If no arguments
   * are provided, the ending point will be the end of the data.
   *
   * The ending point is inclusive, so children with exactly the specified
   * priority will be included. Though if the optional name is specified, then
   * children that have exactly the specified priority must also have a name
   * less than or equal to the specified name.
   *
   * endAt() can be combined with startAt() or limitToFirst() or limitToLast()
   * to create further restrictive queries.
   */
  Query endAt({dynamic value, String key});

  /**
   * Creates a Query which includes children which match the specified value.
   */
  Query equalTo(value, [key]);

  /**
   * Generates a new Query object limited to the first certain number of children.
   */
  Query limitToFirst(int limit);

  /**
   * Generates a new Query object limited to the last certain number of children.
   */
  Query limitToLast(int limit);

  /**
   * Generate a Query object limited to the number of specified children. If
   * combined with startAt, the query will include the specified number of
   * children after the starting point. If combined with endAt, the query will
   * include the specified number of children before the ending point. If not
   * combined with startAt() or endAt(), the query will include the last
   * specified number of children.
   */
  @deprecated
  Query limit(int limit);

  /**
   * Queries are attached to a location in your Firebase. This method will
   * return a Firebase reference to that location.
   */
  DatabaseReference ref();
}
