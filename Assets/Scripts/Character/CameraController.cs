using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class CameraController : MonoBehaviour
{
    [Header("Inputs")]
    private PlayerInput playerInput;
    private InputAction moveCamera;

    [Header("Camera")]
    public Transform m_LookAt;

    float m_Pitch = 0.0f;

    public float m_MinDistance = 2.0f;
    public float m_MaxDistance = 5.0f;

    public float m_YawRotationalSpeed = 360.0f;
    public float m_PitchRotationalSped = 180.0f;

    public float m_MinPitchDistance = 85.0f;
    public float m_MaxPitchDistance = 85.0f;

    public LayerMask m_CollisionLayerMask;

    [Range(0.0f, 1.0f)]
    public float m_CameraSensivity = 0.5f;

    // shoulder aim

    [SerializeField]
    private Transform m_ShoulderCameraPosition;
    [SerializeField]
    private bool m_isAiming;
    [SerializeField]
    private float m_Speed;

    public void SetIsAiming(bool l_isAiming)
    {
        m_isAiming = l_isAiming;
    }

    public bool GetIsAiming()
    {
        return m_isAiming;
    }

    void Start()
    {
        Cursor.lockState = CursorLockMode.Locked;

        playerInput = GetComponent<PlayerInput>();
        moveCamera = playerInput.actions["Look"];
        m_isAiming = false;
        m_Speed = 10f;
    }

    void LateUpdate()
    {
        if (m_isAiming)
        {
            transform.position = Vector3.Lerp(transform.position, m_ShoulderCameraPosition.position, Time.deltaTime * m_Speed);
            transform.forward = m_ShoulderCameraPosition.transform.forward;
        } else
        {
            Vector2 input = moveCamera.ReadValue<Vector2>() * m_CameraSensivity;

            Vector3 l_Direction = m_LookAt.position - transform.position;
            float l_Distance = l_Direction.magnitude;
            l_Distance = Mathf.Clamp(l_Distance, m_MinDistance, m_MaxDistance);
            l_Direction.y = 0.0f;
            l_Direction.Normalize();

            float l_Yaw = Mathf.Atan2(l_Direction.x, l_Direction.z);

            //float l_MouseDeltaX = Input.GetAxis("Mouse X");
            //float l_MouseDeltaY = Input.GetAxis("Mouse Y");

            float l_MouseDeltaX = input.x;
            float l_MouseDeltaY = input.y;

            l_Yaw += l_MouseDeltaX * (m_YawRotationalSpeed * Mathf.Deg2Rad) * Time.deltaTime;
            m_Pitch += l_MouseDeltaY * (m_PitchRotationalSped * Mathf.Deg2Rad) * Time.deltaTime;
            m_Pitch = Mathf.Clamp(m_Pitch, m_MinPitchDistance * Mathf.Deg2Rad, m_MaxPitchDistance * Mathf.Deg2Rad);

            l_Direction = new Vector3(Mathf.Sin(l_Yaw) * Mathf.Cos(m_Pitch), Mathf.Sin(m_Pitch), Mathf.Cos(l_Yaw) * Mathf.Cos(m_Pitch));
            Vector3 l_DesiredPosition = m_LookAt.position - l_Direction * l_Distance;

            Ray l_Ray = new Ray(m_LookAt.position, -l_Direction);
            if (Physics.Raycast(l_Ray, out RaycastHit l_RaycastHit, l_Distance, m_CollisionLayerMask.value))
            {
                l_DesiredPosition = l_RaycastHit.point;
                l_DesiredPosition += l_Direction;
            }
            transform.position = l_DesiredPosition;
            transform.LookAt(m_LookAt.position);
        }
        
    }
}
