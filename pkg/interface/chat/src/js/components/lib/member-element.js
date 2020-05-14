import React, { Component } from 'react';
import { Sigil } from '/components/lib/icons/sigil';
import { uxToHex, cite } from '/lib/util';

export class MemberElement extends Component {
  onRemove() {
    const { props } = this;
    props.api.groups.remove([`~${props.ship}`], props.path);
  }

  render() {
    const { props } = this;

    let actionElem;
    if (props.ship === props.owner) {
      actionElem = (
        <p className="w-20 dib list-ship black white-d f8 c-default">
          Host
        </p>
      );
    } else if (window.ship !== props.ship && window.ship === props.owner) {
      actionElem = (
        <a onClick={this.onRemove.bind(this)}
           className="w-20 dib list-ship black white-d f8 pointer"
        >
           Ban
        </a>
      );
    } else {
      actionElem = (
        <span></span>
      );
    }

    const name = props.contact
      ? `${props.contact.nickname} (${cite(props.ship)})` : `${cite(props.ship)}`;
    const color = props.contact ? uxToHex(props.contact.color) : '000000';

    const img = (props.contact && (props.contact.avatar !== null))
      ? <img src={props.contact.avatar} height={32} width={32} className="dib" />
      : <Sigil ship={props.ship} size={32} color={`#${color}`} />;

    return (
      <div className="flex mb2">
      {img}
        <p className={
            'w-70 mono list-ship dib v-mid black white-d ml2 nowrap f8'
           }
        >{name}</p>
        {actionElem}
      </div>
    );
  }
}

