import { Server } from '@chainlink/ccip-read-server';
import { ethers } from 'ethers';
import { hexConcat } from 'ethers/lib/utils';
import { PrismaClient } from '@prisma/client';
import { withAccelerate } from '@prisma/extension-accelerate';
import { abi } from '@ensdomains/offchain-resolver-contracts/artifacts/contracts/OffchainResolver.sol/IResolverService.json';
import { abi as abi$1 } from '@ensdomains/ens-contracts/artifacts/contracts/resolvers/Resolver.sol/Resolver.json';

function asyncGeneratorStep(n, t, e, r, o, a, c) {
  try {
    var i = n[a](c),
      u = i.value;
  } catch (n) {
    return void e(n);
  }
  i.done ? t(u) : Promise.resolve(u).then(r, o);
}
function _asyncToGenerator(n) {
  return function () {
    var t = this,
      e = arguments;
    return new Promise(function (r, o) {
      var a = n.apply(t, e);
      function _next(n) {
        asyncGeneratorStep(a, r, o, _next, _throw, "next", n);
      }
      function _throw(n) {
        asyncGeneratorStep(a, r, o, _next, _throw, "throw", n);
      }
      _next(void 0);
    });
  };
}
function _regeneratorRuntime() {
  _regeneratorRuntime = function () {
    return e;
  };
  var t,
    e = {},
    r = Object.prototype,
    n = r.hasOwnProperty,
    o = Object.defineProperty || function (t, e, r) {
      t[e] = r.value;
    },
    i = "function" == typeof Symbol ? Symbol : {},
    a = i.iterator || "@@iterator",
    c = i.asyncIterator || "@@asyncIterator",
    u = i.toStringTag || "@@toStringTag";
  function define(t, e, r) {
    return Object.defineProperty(t, e, {
      value: r,
      enumerable: !0,
      configurable: !0,
      writable: !0
    }), t[e];
  }
  try {
    define({}, "");
  } catch (t) {
    define = function (t, e, r) {
      return t[e] = r;
    };
  }
  function wrap(t, e, r, n) {
    var i = e && e.prototype instanceof Generator ? e : Generator,
      a = Object.create(i.prototype),
      c = new Context(n || []);
    return o(a, "_invoke", {
      value: makeInvokeMethod(t, r, c)
    }), a;
  }
  function tryCatch(t, e, r) {
    try {
      return {
        type: "normal",
        arg: t.call(e, r)
      };
    } catch (t) {
      return {
        type: "throw",
        arg: t
      };
    }
  }
  e.wrap = wrap;
  var h = "suspendedStart",
    l = "suspendedYield",
    f = "executing",
    s = "completed",
    y = {};
  function Generator() {}
  function GeneratorFunction() {}
  function GeneratorFunctionPrototype() {}
  var p = {};
  define(p, a, function () {
    return this;
  });
  var d = Object.getPrototypeOf,
    v = d && d(d(values([])));
  v && v !== r && n.call(v, a) && (p = v);
  var g = GeneratorFunctionPrototype.prototype = Generator.prototype = Object.create(p);
  function defineIteratorMethods(t) {
    ["next", "throw", "return"].forEach(function (e) {
      define(t, e, function (t) {
        return this._invoke(e, t);
      });
    });
  }
  function AsyncIterator(t, e) {
    function invoke(r, o, i, a) {
      var c = tryCatch(t[r], t, o);
      if ("throw" !== c.type) {
        var u = c.arg,
          h = u.value;
        return h && "object" == typeof h && n.call(h, "__await") ? e.resolve(h.__await).then(function (t) {
          invoke("next", t, i, a);
        }, function (t) {
          invoke("throw", t, i, a);
        }) : e.resolve(h).then(function (t) {
          u.value = t, i(u);
        }, function (t) {
          return invoke("throw", t, i, a);
        });
      }
      a(c.arg);
    }
    var r;
    o(this, "_invoke", {
      value: function (t, n) {
        function callInvokeWithMethodAndArg() {
          return new e(function (e, r) {
            invoke(t, n, e, r);
          });
        }
        return r = r ? r.then(callInvokeWithMethodAndArg, callInvokeWithMethodAndArg) : callInvokeWithMethodAndArg();
      }
    });
  }
  function makeInvokeMethod(e, r, n) {
    var o = h;
    return function (i, a) {
      if (o === f) throw Error("Generator is already running");
      if (o === s) {
        if ("throw" === i) throw a;
        return {
          value: t,
          done: !0
        };
      }
      for (n.method = i, n.arg = a;;) {
        var c = n.delegate;
        if (c) {
          var u = maybeInvokeDelegate(c, n);
          if (u) {
            if (u === y) continue;
            return u;
          }
        }
        if ("next" === n.method) n.sent = n._sent = n.arg;else if ("throw" === n.method) {
          if (o === h) throw o = s, n.arg;
          n.dispatchException(n.arg);
        } else "return" === n.method && n.abrupt("return", n.arg);
        o = f;
        var p = tryCatch(e, r, n);
        if ("normal" === p.type) {
          if (o = n.done ? s : l, p.arg === y) continue;
          return {
            value: p.arg,
            done: n.done
          };
        }
        "throw" === p.type && (o = s, n.method = "throw", n.arg = p.arg);
      }
    };
  }
  function maybeInvokeDelegate(e, r) {
    var n = r.method,
      o = e.iterator[n];
    if (o === t) return r.delegate = null, "throw" === n && e.iterator.return && (r.method = "return", r.arg = t, maybeInvokeDelegate(e, r), "throw" === r.method) || "return" !== n && (r.method = "throw", r.arg = new TypeError("The iterator does not provide a '" + n + "' method")), y;
    var i = tryCatch(o, e.iterator, r.arg);
    if ("throw" === i.type) return r.method = "throw", r.arg = i.arg, r.delegate = null, y;
    var a = i.arg;
    return a ? a.done ? (r[e.resultName] = a.value, r.next = e.nextLoc, "return" !== r.method && (r.method = "next", r.arg = t), r.delegate = null, y) : a : (r.method = "throw", r.arg = new TypeError("iterator result is not an object"), r.delegate = null, y);
  }
  function pushTryEntry(t) {
    var e = {
      tryLoc: t[0]
    };
    1 in t && (e.catchLoc = t[1]), 2 in t && (e.finallyLoc = t[2], e.afterLoc = t[3]), this.tryEntries.push(e);
  }
  function resetTryEntry(t) {
    var e = t.completion || {};
    e.type = "normal", delete e.arg, t.completion = e;
  }
  function Context(t) {
    this.tryEntries = [{
      tryLoc: "root"
    }], t.forEach(pushTryEntry, this), this.reset(!0);
  }
  function values(e) {
    if (e || "" === e) {
      var r = e[a];
      if (r) return r.call(e);
      if ("function" == typeof e.next) return e;
      if (!isNaN(e.length)) {
        var o = -1,
          i = function next() {
            for (; ++o < e.length;) if (n.call(e, o)) return next.value = e[o], next.done = !1, next;
            return next.value = t, next.done = !0, next;
          };
        return i.next = i;
      }
    }
    throw new TypeError(typeof e + " is not iterable");
  }
  return GeneratorFunction.prototype = GeneratorFunctionPrototype, o(g, "constructor", {
    value: GeneratorFunctionPrototype,
    configurable: !0
  }), o(GeneratorFunctionPrototype, "constructor", {
    value: GeneratorFunction,
    configurable: !0
  }), GeneratorFunction.displayName = define(GeneratorFunctionPrototype, u, "GeneratorFunction"), e.isGeneratorFunction = function (t) {
    var e = "function" == typeof t && t.constructor;
    return !!e && (e === GeneratorFunction || "GeneratorFunction" === (e.displayName || e.name));
  }, e.mark = function (t) {
    return Object.setPrototypeOf ? Object.setPrototypeOf(t, GeneratorFunctionPrototype) : (t.__proto__ = GeneratorFunctionPrototype, define(t, u, "GeneratorFunction")), t.prototype = Object.create(g), t;
  }, e.awrap = function (t) {
    return {
      __await: t
    };
  }, defineIteratorMethods(AsyncIterator.prototype), define(AsyncIterator.prototype, c, function () {
    return this;
  }), e.AsyncIterator = AsyncIterator, e.async = function (t, r, n, o, i) {
    void 0 === i && (i = Promise);
    var a = new AsyncIterator(wrap(t, r, n, o), i);
    return e.isGeneratorFunction(r) ? a : a.next().then(function (t) {
      return t.done ? t.value : a.next();
    });
  }, defineIteratorMethods(g), define(g, u, "Generator"), define(g, a, function () {
    return this;
  }), define(g, "toString", function () {
    return "[object Generator]";
  }), e.keys = function (t) {
    var e = Object(t),
      r = [];
    for (var n in e) r.push(n);
    return r.reverse(), function next() {
      for (; r.length;) {
        var t = r.pop();
        if (t in e) return next.value = t, next.done = !1, next;
      }
      return next.done = !0, next;
    };
  }, e.values = values, Context.prototype = {
    constructor: Context,
    reset: function (e) {
      if (this.prev = 0, this.next = 0, this.sent = this._sent = t, this.done = !1, this.delegate = null, this.method = "next", this.arg = t, this.tryEntries.forEach(resetTryEntry), !e) for (var r in this) "t" === r.charAt(0) && n.call(this, r) && !isNaN(+r.slice(1)) && (this[r] = t);
    },
    stop: function () {
      this.done = !0;
      var t = this.tryEntries[0].completion;
      if ("throw" === t.type) throw t.arg;
      return this.rval;
    },
    dispatchException: function (e) {
      if (this.done) throw e;
      var r = this;
      function handle(n, o) {
        return a.type = "throw", a.arg = e, r.next = n, o && (r.method = "next", r.arg = t), !!o;
      }
      for (var o = this.tryEntries.length - 1; o >= 0; --o) {
        var i = this.tryEntries[o],
          a = i.completion;
        if ("root" === i.tryLoc) return handle("end");
        if (i.tryLoc <= this.prev) {
          var c = n.call(i, "catchLoc"),
            u = n.call(i, "finallyLoc");
          if (c && u) {
            if (this.prev < i.catchLoc) return handle(i.catchLoc, !0);
            if (this.prev < i.finallyLoc) return handle(i.finallyLoc);
          } else if (c) {
            if (this.prev < i.catchLoc) return handle(i.catchLoc, !0);
          } else {
            if (!u) throw Error("try statement without catch or finally");
            if (this.prev < i.finallyLoc) return handle(i.finallyLoc);
          }
        }
      }
    },
    abrupt: function (t, e) {
      for (var r = this.tryEntries.length - 1; r >= 0; --r) {
        var o = this.tryEntries[r];
        if (o.tryLoc <= this.prev && n.call(o, "finallyLoc") && this.prev < o.finallyLoc) {
          var i = o;
          break;
        }
      }
      i && ("break" === t || "continue" === t) && i.tryLoc <= e && e <= i.finallyLoc && (i = null);
      var a = i ? i.completion : {};
      return a.type = t, a.arg = e, i ? (this.method = "next", this.next = i.finallyLoc, y) : this.complete(a);
    },
    complete: function (t, e) {
      if ("throw" === t.type) throw t.arg;
      return "break" === t.type || "continue" === t.type ? this.next = t.arg : "return" === t.type ? (this.rval = this.arg = t.arg, this.method = "return", this.next = "end") : "normal" === t.type && e && (this.next = e), y;
    },
    finish: function (t) {
      for (var e = this.tryEntries.length - 1; e >= 0; --e) {
        var r = this.tryEntries[e];
        if (r.finallyLoc === t) return this.complete(r.completion, r.afterLoc), resetTryEntry(r), y;
      }
    },
    catch: function (t) {
      for (var e = this.tryEntries.length - 1; e >= 0; --e) {
        var r = this.tryEntries[e];
        if (r.tryLoc === t) {
          var n = r.completion;
          if ("throw" === n.type) {
            var o = n.arg;
            resetTryEntry(r);
          }
          return o;
        }
      }
      throw Error("illegal catch attempt");
    },
    delegateYield: function (e, r, n) {
      return this.delegate = {
        iterator: values(e),
        resultName: r,
        nextLoc: n
      }, "next" === this.method && (this.arg = t), y;
    }
  }, e;
}

var ETH_COIN_TYPE = 60;

var _globalThis$prismaGlo;
// Learn more about instantiating PrismaClient in Next.js here: https://www.prisma.io/docs/data-platform/accelerate/getting-started
var prismaClientSingleton = function prismaClientSingleton() {
  return new PrismaClient().$extends(withAccelerate());
};
var prisma = (_globalThis$prismaGlo = globalThis.prismaGlobal) != null ? _globalThis$prismaGlo : /*#__PURE__*/prismaClientSingleton();
if (process.env.NODE_ENV !== "production") globalThis.prismaGlobal = prisma;

var getAddress = /*#__PURE__*/function () {
  var _ref = /*#__PURE__*/_asyncToGenerator( /*#__PURE__*/_regeneratorRuntime().mark(function _callee(node) {
    return _regeneratorRuntime().wrap(function _callee$(_context) {
      while (1) switch (_context.prev = _context.next) {
        case 0:
          _context.next = 2;
          return prisma.ens.findUnique({
            // @ts-ignore
            where: {
              node: node
            },
            select: {
              address: true
            }
          });
        case 2:
          return _context.abrupt("return", _context.sent);
        case 3:
        case "end":
          return _context.stop();
      }
    }, _callee);
  }));
  return function getAddress(_x) {
    return _ref.apply(this, arguments);
  };
}();
var getText = /*#__PURE__*/function () {
  var _ref2 = /*#__PURE__*/_asyncToGenerator( /*#__PURE__*/_regeneratorRuntime().mark(function _callee2(node) {
    return _regeneratorRuntime().wrap(function _callee2$(_context2) {
      while (1) switch (_context2.prev = _context2.next) {
        case 0:
          _context2.next = 2;
          return prisma.ens.findUnique({
            // @ts-ignore
            where: {
              node: node
            },
            select: {
              text: true
            }
          });
        case 2:
          return _context2.abrupt("return", _context2.sent);
        case 3:
        case "end":
          return _context2.stop();
      }
    }, _callee2);
  }));
  return function getText(_x2) {
    return _ref2.apply(this, arguments);
  };
}();
var getContenthash = /*#__PURE__*/function () {
  var _ref3 = /*#__PURE__*/_asyncToGenerator( /*#__PURE__*/_regeneratorRuntime().mark(function _callee3(node) {
    return _regeneratorRuntime().wrap(function _callee3$(_context3) {
      while (1) switch (_context3.prev = _context3.next) {
        case 0:
          _context3.next = 2;
          return prisma.ens.findUnique({
            // @ts-ignore
            where: {
              node: node
            },
            select: {
              contenthash: true
            }
          });
        case 2:
          return _context3.abrupt("return", _context3.sent);
        case 3:
        case "end":
          return _context3.stop();
      }
    }, _callee3);
  }));
  return function getContenthash(_x3) {
    return _ref3.apply(this, arguments);
  };
}();

var ZERO_ADDRESS = '0x0000000000000000000000000000000000000000';
var EMPTY_CONTENT_HASH = '0x';
var ttl = 300;
function addr(_x, _x2) {
  return _addr.apply(this, arguments);
}
function _addr() {
  _addr = _asyncToGenerator( /*#__PURE__*/_regeneratorRuntime().mark(function _callee(name, coinType) {
    var _addresses, addresses, _addr2;
    return _regeneratorRuntime().wrap(function _callee$(_context) {
      while (1) switch (_context.prev = _context.next) {
        case 0:
          _context.prev = 0;
          _context.next = 3;
          return getAddress(name);
        case 3:
          addresses = _context.sent;
          // @ts-ignore
          addresses = (_addresses = addresses) == null ? void 0 : _addresses.address;
          _addr2 = ZERO_ADDRESS; // @ts-ignore
          if (addresses && addresses[coinType]) {
            // @ts-ignore
            _addr2 = '' + addresses[coinType];
          }
          return _context.abrupt("return", {
            addr: _addr2,
            ttl: ttl
          });
        case 10:
          _context.prev = 10;
          _context.t0 = _context["catch"](0);
          return _context.abrupt("return", {
            addr: ZERO_ADDRESS,
            ttl: ttl
          });
        case 13:
        case "end":
          return _context.stop();
      }
    }, _callee, null, [[0, 10]]);
  }));
  return _addr.apply(this, arguments);
}
function text(_x3, _x4) {
  return _text.apply(this, arguments);
}
function _text() {
  _text = _asyncToGenerator( /*#__PURE__*/_regeneratorRuntime().mark(function _callee2(name, key) {
    var texts, _text2;
    return _regeneratorRuntime().wrap(function _callee2$(_context2) {
      while (1) switch (_context2.prev = _context2.next) {
        case 0:
          _context2.prev = 0;
          _context2.next = 3;
          return getText(name);
        case 3:
          texts = _context2.sent;
          // @ts-ignore
          _text2 = texts == null ? void 0 : texts.text; // @ts-ignore
          if (!(_text2 && _text2[key])) {
            _context2.next = 9;
            break;
          }
          return _context2.abrupt("return", {
            value: _text2[key],
            ttl: ttl
          });
        case 9:
          return _context2.abrupt("return", {
            value: '',
            ttl: ttl
          });
        case 10:
          _context2.next = 15;
          break;
        case 12:
          _context2.prev = 12;
          _context2.t0 = _context2["catch"](0);
          return _context2.abrupt("return", {
            value: '',
            ttl: ttl
          });
        case 15:
        case "end":
          return _context2.stop();
      }
    }, _callee2, null, [[0, 12]]);
  }));
  return _text.apply(this, arguments);
}
function contenthash(_x5) {
  return _contenthash.apply(this, arguments);
}
function _contenthash() {
  _contenthash = _asyncToGenerator( /*#__PURE__*/_regeneratorRuntime().mark(function _callee3(name) {
    var contenthashRes, _contenthash2;
    return _regeneratorRuntime().wrap(function _callee3$(_context3) {
      while (1) switch (_context3.prev = _context3.next) {
        case 0:
          _context3.prev = 0;
          _context3.next = 3;
          return getContenthash(name);
        case 3:
          contenthashRes = _context3.sent;
          // @ts-ignore
          _contenthash2 = contenthashRes == null ? void 0 : contenthashRes.contenthash;
          if (!_contenthash2) {
            _context3.next = 9;
            break;
          }
          return _context3.abrupt("return", {
            contenthash: _contenthash2,
            ttl: ttl
          });
        case 9:
          return _context3.abrupt("return", {
            contenthash: EMPTY_CONTENT_HASH,
            ttl: ttl
          });
        case 10:
          _context3.next = 15;
          break;
        case 12:
          _context3.prev = 12;
          _context3.t0 = _context3["catch"](0);
          return _context3.abrupt("return", {
            contenthash: EMPTY_CONTENT_HASH,
            ttl: ttl
          });
        case 15:
        case "end":
          return _context3.stop();
      }
    }, _callee3, null, [[0, 12]]);
  }));
  return _contenthash.apply(this, arguments);
}

var Resolver = /*#__PURE__*/new ethers.utils.Interface(abi$1);
function decodeDnsName(dnsname) {
  var labels = [];
  var idx = 0;
  while (true) {
    var len = dnsname.readUInt8(idx);
    if (len === 0) break;
    labels.push(dnsname.slice(idx + 1, idx + len + 1).toString('utf8'));
    idx += len + 1;
  }
  return labels.join('.');
}
var queryHandlers = {
  'addr(bytes32)': ( /*#__PURE__*/function () {
    var _addrBytes = /*#__PURE__*/_asyncToGenerator( /*#__PURE__*/_regeneratorRuntime().mark(function _callee(name, _args) {
      var _yield$getAddr, addr$1, ttl;
      return _regeneratorRuntime().wrap(function _callee$(_context) {
        while (1) switch (_context.prev = _context.next) {
          case 0:
            _context.next = 2;
            return addr(name, ETH_COIN_TYPE);
          case 2:
            _yield$getAddr = _context.sent;
            addr$1 = _yield$getAddr.addr;
            ttl = _yield$getAddr.ttl;
            return _context.abrupt("return", {
              result: [addr$1],
              ttl: ttl
            });
          case 6:
          case "end":
            return _context.stop();
        }
      }, _callee);
    }));
    function addrBytes32(_x, _x2) {
      return _addrBytes.apply(this, arguments);
    }
    return addrBytes32;
  }()),
  'addr(bytes32,uint256)': ( /*#__PURE__*/function () {
    var _addrBytes32Uint = /*#__PURE__*/_asyncToGenerator( /*#__PURE__*/_regeneratorRuntime().mark(function _callee2(name, args) {
      var _yield$getAddr2, addr$1, ttl;
      return _regeneratorRuntime().wrap(function _callee2$(_context2) {
        while (1) switch (_context2.prev = _context2.next) {
          case 0:
            _context2.next = 2;
            return addr(name, args[0]);
          case 2:
            _yield$getAddr2 = _context2.sent;
            addr$1 = _yield$getAddr2.addr;
            ttl = _yield$getAddr2.ttl;
            return _context2.abrupt("return", {
              result: [addr$1],
              ttl: ttl
            });
          case 6:
          case "end":
            return _context2.stop();
        }
      }, _callee2);
    }));
    function addrBytes32Uint256(_x3, _x4) {
      return _addrBytes32Uint.apply(this, arguments);
    }
    return addrBytes32Uint256;
  }()),
  'text(bytes32,string)': ( /*#__PURE__*/function () {
    var _textBytes32String = /*#__PURE__*/_asyncToGenerator( /*#__PURE__*/_regeneratorRuntime().mark(function _callee3(name, args) {
      var _yield$text, value, ttl;
      return _regeneratorRuntime().wrap(function _callee3$(_context3) {
        while (1) switch (_context3.prev = _context3.next) {
          case 0:
            _context3.next = 2;
            return text(name, args[0]);
          case 2:
            _yield$text = _context3.sent;
            value = _yield$text.value;
            ttl = _yield$text.ttl;
            return _context3.abrupt("return", {
              result: [value],
              ttl: ttl
            });
          case 6:
          case "end":
            return _context3.stop();
        }
      }, _callee3);
    }));
    function textBytes32String(_x5, _x6) {
      return _textBytes32String.apply(this, arguments);
    }
    return textBytes32String;
  }()),
  'contenthash(bytes32)': ( /*#__PURE__*/function () {
    var _contenthashBytes = /*#__PURE__*/_asyncToGenerator( /*#__PURE__*/_regeneratorRuntime().mark(function _callee4(name, _args) {
      var _yield$getContentHash, contenthash$1, ttl;
      return _regeneratorRuntime().wrap(function _callee4$(_context4) {
        while (1) switch (_context4.prev = _context4.next) {
          case 0:
            _context4.next = 2;
            return contenthash(name);
          case 2:
            _yield$getContentHash = _context4.sent;
            contenthash$1 = _yield$getContentHash.contenthash;
            ttl = _yield$getContentHash.ttl;
            return _context4.abrupt("return", {
              result: [contenthash$1],
              ttl: ttl
            });
          case 6:
          case "end":
            return _context4.stop();
        }
      }, _callee4);
    }));
    function contenthashBytes32(_x7, _x8) {
      return _contenthashBytes.apply(this, arguments);
    }
    return contenthashBytes32;
  }())
};
function query(_x9, _x10) {
  return _query.apply(this, arguments);
}
function _query() {
  _query = _asyncToGenerator( /*#__PURE__*/_regeneratorRuntime().mark(function _callee6(name, data) {
    var _Resolver$parseTransa, signature, args, handler, _yield$handler, result, ttl;
    return _regeneratorRuntime().wrap(function _callee6$(_context6) {
      while (1) switch (_context6.prev = _context6.next) {
        case 0:
          // Parse the data nested inside the second argument to `resolve`
          _Resolver$parseTransa = Resolver.parseTransaction({
            data: data
          }), signature = _Resolver$parseTransa.signature, args = _Resolver$parseTransa.args;
          if (!(ethers.utils.nameprep(name) !== name)) {
            _context6.next = 3;
            break;
          }
          throw new Error('Name must be normalised');
        case 3:
          if (!(ethers.utils.namehash(name) !== args[0])) {
            _context6.next = 5;
            break;
          }
          throw new Error('Name does not match namehash');
        case 5:
          handler = queryHandlers[signature];
          if (!(handler === undefined)) {
            _context6.next = 8;
            break;
          }
          throw new Error("Unsupported query function " + signature);
        case 8:
          _context6.next = 10;
          return handler(name, args.slice(1));
        case 10:
          _yield$handler = _context6.sent;
          result = _yield$handler.result;
          ttl = _yield$handler.ttl;
          return _context6.abrupt("return", {
            result: Resolver.encodeFunctionResult(signature, result),
            validUntil: Math.floor(Date.now() / 1000 + ttl)
          });
        case 14:
        case "end":
          return _context6.stop();
      }
    }, _callee6);
  }));
  return _query.apply(this, arguments);
}
function makeServer(signer) {
  var server = new Server();
  server.add(abi, [{
    type: 'resolve',
    func: function () {
      var _func = _asyncToGenerator( /*#__PURE__*/_regeneratorRuntime().mark(function _callee5(_ref, request) {
        var encodedName, data, name, _yield$query, result, validUntil, messageHash, sig, sigData;
        return _regeneratorRuntime().wrap(function _callee5$(_context5) {
          while (1) switch (_context5.prev = _context5.next) {
            case 0:
              encodedName = _ref[0], data = _ref[1];
              name = decodeDnsName(Buffer.from(encodedName.slice(2), 'hex')); // Query the database
              _context5.next = 4;
              return query(name, data);
            case 4:
              _yield$query = _context5.sent;
              result = _yield$query.result;
              validUntil = _yield$query.validUntil;
              // Hash and sign the response
              messageHash = ethers.utils.solidityKeccak256(['bytes', 'address', 'uint64', 'bytes32', 'bytes32'], ['0x1900', request == null ? void 0 : request.to, validUntil, ethers.utils.keccak256((request == null ? void 0 : request.data) || '0x'), ethers.utils.keccak256(result)]);
              sig = signer.signDigest(messageHash);
              sigData = hexConcat([sig.r, sig._vs]);
              return _context5.abrupt("return", [result, validUntil, sigData]);
            case 11:
            case "end":
              return _context5.stop();
          }
        }, _callee5);
      }));
      function func(_x11, _x12) {
        return _func.apply(this, arguments);
      }
      return func;
    }()
  }]);
  return server;
}
function makeApp(signer, path) {
  return makeServer(signer).makeApp(path);
}

// const program = new Command();
// program
//   .requiredOption(
//     '-k --private-key <key>',
//     'Private key to sign responses with. Prefix with @ to read from a file'
//   )
//   // .requiredOption('-d --data <file>', 'JSON file to read data from')
//   // .option('-t --ttl <number>', 'TTL for signatures', '300')
//   .option('-p --port <number>', 'Port number to serve on', '8080');
// program.parse(process.argv);
// const options = program.opts();
var privateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";
var port = 10000;
// if (privateKey.startsWith('@')) {
//   privateKey = ethers.utils.arrayify(
//     readFileSync(privateKey.slice(1), { encoding: 'utf-8' })
//   );
// }
var address = /*#__PURE__*/ethers.utils.computeAddress(privateKey);
var signer = /*#__PURE__*/new ethers.utils.SigningKey(privateKey);
var app = /*#__PURE__*/makeApp(signer, '/');
console.log("Serving on port " + port + " with signing address " + address);
app.listen(port);
//# sourceMappingURL=comet-ens-serve.esm.js.map
