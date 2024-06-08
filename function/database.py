# coding: utf-8

from typing import Any, Optional
from xmlrpc.client import DateTime

from firebase_admin import firestore


def get_template_overlays(id: str) -> list[dict[str, Any]]:
    db = firestore.client()

    template_document_ref = db.collection('systemMedia').document(id)
    template_document = template_document_ref.get()
    template_data = template_document.to_dict()
    return template_data['overlays']


def get_registration_tokens(uid: str) -> Optional[list[str]]:
    db = firestore.client()

    user_document_ref = db.collection('users').document(uid)
    user_document = user_document_ref.get()
    if not user_document.exists:
        return None

    user_data = user_document.to_dict()

    if 'registrationTokens' not in user_data:
        return None

    return user_data['registrationTokens']


def set_generating_piece(
    uid: str,
    display_name: str,
    thumbnail_file_name: str,
    submitted_at: DateTime
) -> str:
    store_data = {
        'name': display_name,
        'thumbnailFileName': thumbnail_file_name,
        'submittedAt': submitted_at,
    }

    db = firestore.client()

    _, created_document = db.collection('userMedia').document(
        uid).collection('generatedPieces').add(store_data)

    return created_document.id


def set_generated_piece(
    uid: str,
    id: str,
    display_name: str,
    thumbnail_file_name: str,
    movie_file_name: str,
    generated_at: DateTime
):
    store_data = {
        'name': display_name,
        'thumbnailFileName': thumbnail_file_name,
        'movieFileName': movie_file_name,
        'generatedAt': generated_at,
    }

    db = firestore.client()

    generated_pieces_collection = db.collection('userMedia').document(
        uid).collection('generatedPieces')

    generated_pieces_collection.document(id).update(store_data)


def set_template(
    default_name: str,
    published_at: DateTime,
    overlays: list[dict[str, Any]],
) -> str:
    store_data = {
        'name': default_name, # for older version
        'defaultName': default_name,
        'publishedAt': published_at,
        'overlays': overlays,
    }

    db = firestore.client()

    system_media_ref = db.collection('systemMedia')

    _, created_document = system_media_ref.add(store_data)

    return created_document.id


def set_localized_template_metadata(
    language_tag: str,
    template_id: str,
    localized_name: str,
) -> str:
    store_data = {
        'name': localized_name,
    }

    db = firestore.client()

    template_doc_ref = db.collection('localized')\
        .document(language_tag)\
        .collection('systemMedia')\
        .document(template_id)

    template_doc_ref.set(store_data)
