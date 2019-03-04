import React from 'react';
import ReactDOM from 'react-dom';
import {App} from './App';

ReactDOM.render(<App />, document.getElementById('root'));

// hot-reload currently cause problems because of event subscriptions in components constructors
// for example, see LayoutComponent.tsx
// https://github.com/gaearon/react-hot-loader/blob/master/docs/Troubleshooting.md
// if ((module as any).hot) {
//    ;(module as any).hot.accept();
//    ;(module as any).hot.dispose(() => {
//    });
// }
