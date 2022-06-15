using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RagdollController : MonoBehaviour
{
    [SerializeField]
    private Animator m_animator;

    [SerializeField]
    private CharacterController m_characterController;

    private Rigidbody[] m_rigidbodies;
    private Collider[] m_colliders;

    private void Awake()
    {
        m_rigidbodies = GetComponentsInChildren<Rigidbody>();
        m_colliders = GetComponentsInChildren<Collider>();

        SetCollidersEnabled(false);
        SetRigidbodyEnabled(true);

    }

    private void SetRigidbodyEnabled(bool l_enabled)
    {
        foreach (Rigidbody l_rb in m_rigidbodies)
        {
            l_rb.isKinematic = l_enabled;
        }
    }

    private void SetCollidersEnabled(bool l_enabled)
    {
        foreach (Collider l_col in m_colliders)
        {
            l_col.enabled = l_enabled;
        }
    }

    public void EnableRagdoll()
    {

        m_characterController.enabled = false;
        m_animator.enabled = false;

        SetCollidersEnabled(true);
        SetRigidbodyEnabled(false);
    }

    public void DisableRagdoll()
    {
        m_characterController.enabled = true;
        m_animator.enabled = true;

        SetCollidersEnabled(false);
        SetRigidbodyEnabled(true);

    }

}
