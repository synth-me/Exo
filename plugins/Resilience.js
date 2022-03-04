// Generated by LiveScript 1.6.0
(function(){
  var ref$, any, all, at, filter, map, head, last, intersection, difference, flatten, zip, zipWith, Str, concat, flip, reverse, breakList, elemIndex, take, drop, maximumBy, maximum, union, initial, split, Func, Num, isType, mqtt, fs, similarity, KNN, colors, art, cliProgress, express, commandline_argument, MVar, IO, MODEL, LOG, checkFile, process, Resilience, out$ = typeof exports != 'undefined' && exports || this;
  ref$ = require("prelude-ls"), any = ref$.any, all = ref$.all, at = ref$.at, filter = ref$.filter, map = ref$.map, head = ref$.head, last = ref$.last, intersection = ref$.intersection, difference = ref$.difference, flatten = ref$.flatten, zip = ref$.zip, zipWith = ref$.zipWith, Str = ref$.Str, concat = ref$.concat, flip = ref$.flip, reverse = ref$.reverse, breakList = ref$.breakList, elemIndex = ref$.elemIndex, take = ref$.take, drop = ref$.drop, maximumBy = ref$.maximumBy, maximum = ref$.maximum, union = ref$.union, initial = ref$.initial, split = ref$.split, Func = ref$.Func, Num = ref$.Num, isType = ref$.isType;
  mqtt = require("mqtt");
  fs = require("fs");
  similarity = require("compute-cosine-similarity");
  KNN = require("ml-knn");
  colors = require("colors");
  art = require("ascii-art");
  cliProgress = require("cli-progress");
  express = require("express");
  commandline_argument = require("process");
  MVar = {};
  IO = (function(){
    IO.displayName = 'IO';
    var prototype = IO.prototype, constructor = IO;
    IO.puts = function(it){
      return console.log(it);
    };
    IO.read = function(it){
      return fs.readFileSync(it, "utf-8");
    };
    IO.write = function(path, content){
      return fs.writeFileSync(path, content);
    };
    IO.minsert = function(mvar, content){
      return mvar[0] = content;
    };
    function IO(){}
    return IO;
  }());
  MODEL = (function(){
    MODEL.displayName = 'MODEL';
    var prototype = MODEL.prototype, constructor = MODEL;
    MODEL.path = function(it){
      return "./models/" + it + ".json";
    };
    MODEL.list = "./modelList.json";
    function MODEL(){}
    return MODEL;
  }());
  LOG = (function(){
    LOG.displayName = 'LOG';
    var prototype = LOG.prototype, constructor = LOG;
    LOG.puts = function(it){
      return IO.puts("----------- \n " + it + " \n-----------");
    };
    LOG.alert = function(it){
      return console.log(("----------- \n ALERT :: \n " + it + " \n-----------").yellow);
    };
    LOG.spawn = function(it){
      return console.log(("----------- \n " + it + " \n-----------").green);
    };
    function LOG(){}
    return LOG;
  }());
  checkFile = function(name, content, mode){
    var data, i, e, formatted;
    switch (false) {
    case !(fs.existsSync(
    MODEL.path(
    name)) && mode === "train"):
      data = JSON.parse(
      IO.read(
      MODEL.path(
      name)));
      data.f_dataset.push(content);
      IO.write(MODEL.path(name), JSON.stringify(
      data));
      IO.puts(
      "New " + content + " written in " + name);
      return 1;
    case !(fs.existsSync(
      MODEL.path(
      name)) && mode !== "train"):
      data = function(it){
        return it.f_dataset;
      }(
      JSON.parse(
      IO.read(
      MODEL.path(
      name))));
      try {
        return function(model){
          var p;
          p = model.predict([content]);
          return compose$(head, head)(
          maximumBy(last)(
          map(function(it){
            return [
              it, similarity(content, head(
              it))
            ];
          })(
          filter(function(it){
            return deepEq$(last(it), p, '===');
          })(
          zip(data)(
          map(function(u){
            return model.predict(
            [u]);
          })(
          data))))));
        }(
        new KNN(data, (function(){
          var i$, to$, results$ = [];
          for (i$ = 0, to$ = data.length - 1; i$ <= to$; ++i$) {
            i = i$;
            results$.push(i);
          }
          return results$;
        }()), {
          k: 1
        }));
      } catch (e$) {
        e = e$;
        IO.puts("Could not classify " + content);
        return 0;
      }
    case !(!fs.existsSync(
      MODEL.path(
      name)) && mode === "train"):
      formatted = JSON.stringify(
      {
        f_dataset: [content]
      });
      IO.write(MODEL.path(
      name), formatted);
      IO.puts(
      "New " + content + " written in new model " + name);
      return 1;
    case !(!fs.existsSync(
      MODEL.path(
      name)) && mode !== "train"):
      return 0;
    }
  };
  process = function(message, client){
    var decoded, vector, mode_t, name, c, d, v;
    decoded = message;
    vector = map(function(x){
      if (isType("Number", x)) {
        return x;
      } else {
        return 1.0;
      }
    })(
    map(last)(
    decoded.moment_data));
    mode_t = decoded.mode;
    name = decoded.name_log;
    c = checkFile(name, vector, mode_t);
    switch (c) {
    case 0:
      client.publish("notifications", "error on " + name + " resilience model");
      break;
    case 1:
      client.publish("notifications", "training " + name + " ...");
      break;
    default:
      client.publish("notifications", "Resilience is on ! check the " + name + " aggregator ...");
    }
    if (c !== 0 && c !== 1) {
      d = zipWith(function(x, y){
        return [head(x), y];
      }, decoded.moment_data, c);
      v = JSON.stringify(
      {
        name_log: decoded.name_log,
        current_data: d
      });
      return v;
    } else {
      return {};
    }
  };
  Resilience = {
    process_data: process
  };
  out$.Resilience = Resilience;
  function compose$() {
    var functions = arguments;
    return function() {
      var i, result;
      result = functions[0].apply(this, arguments);
      for (i = 1; i < functions.length; ++i) {
        result = functions[i](result);
      }
      return result;
    };
  }
  function deepEq$(x, y, type){
    var toString = {}.toString, hasOwnProperty = {}.hasOwnProperty,
        has = function (obj, key) { return hasOwnProperty.call(obj, key); };
    var first = true;
    return eq(x, y, []);
    function eq(a, b, stack) {
      var className, length, size, result, alength, blength, r, key, ref, sizeB;
      if (a == null || b == null) { return a === b; }
      if (a.__placeholder__ || b.__placeholder__) { return true; }
      if (a === b) { return a !== 0 || 1 / a == 1 / b; }
      className = toString.call(a);
      if (toString.call(b) != className) { return false; }
      switch (className) {
        case '[object String]': return a == String(b);
        case '[object Number]':
          return a != +a ? b != +b : (a == 0 ? 1 / a == 1 / b : a == +b);
        case '[object Date]':
        case '[object Boolean]':
          return +a == +b;
        case '[object RegExp]':
          return a.source == b.source &&
                 a.global == b.global &&
                 a.multiline == b.multiline &&
                 a.ignoreCase == b.ignoreCase;
      }
      if (typeof a != 'object' || typeof b != 'object') { return false; }
      length = stack.length;
      while (length--) { if (stack[length] == a) { return true; } }
      stack.push(a);
      size = 0;
      result = true;
      if (className == '[object Array]') {
        alength = a.length;
        blength = b.length;
        if (first) {
          switch (type) {
          case '===': result = alength === blength; break;
          case '<==': result = alength <= blength; break;
          case '<<=': result = alength < blength; break;
          }
          size = alength;
          first = false;
        } else {
          result = alength === blength;
          size = alength;
        }
        if (result) {
          while (size--) {
            if (!(result = size in a == size in b && eq(a[size], b[size], stack))){ break; }
          }
        }
      } else {
        if ('constructor' in a != 'constructor' in b || a.constructor != b.constructor) {
          return false;
        }
        for (key in a) {
          if (has(a, key)) {
            size++;
            if (!(result = has(b, key) && eq(a[key], b[key], stack))) { break; }
          }
        }
        if (result) {
          sizeB = 0;
          for (key in b) {
            if (has(b, key)) { ++sizeB; }
          }
          if (first) {
            if (type === '<<=') {
              result = size < sizeB;
            } else if (type === '<==') {
              result = size <= sizeB
            } else {
              result = size === sizeB;
            }
          } else {
            first = false;
            result = size === sizeB;
          }
        }
      }
      stack.pop();
      return result;
    }
  }
}).call(this);
